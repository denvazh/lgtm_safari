gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
del = require 'del'
intermediate = require 'gulp-intermediate'
jsoneditor = require 'gulp-json-editor'
plist = require 'plist'
plumber = require 'gulp-plumber'
rev = require 'gulp-rev'
sourcemaps = require 'gulp-sourcemaps'
spawn = require('child_process').spawn
tap = require 'gulp-tap'
uglify = require 'gulp-uglify'
usemin = require 'gulp-usemin2'
wiredep = require('wiredep').stream

util = require 'util'

src =
  dir: ['src']
  scripts: ['**/*.coffee']
  global: ['global.html']

dest =
  dir: 'lgtm.safariextension'

# cleanup compiled javascript files
gulp.task 'clean', (callback)->
  del([
    [].concat(dest.dir,'**/*.js').join('/'),
    [].concat(dest.dir,src.global).join('/')
  ], callback)

# inject bower dependencies
gulp.task 'wiredep', ->
  gulp.src(src.dir.concat(src.global).join('/'))
    .pipe(wiredep({
      directory: './bower_components',
      bowerJson: require('./bower.json')
    }))
    .pipe(gulp.dest(src.dir.concat('/').join('')))

# merge all dependencies into single file
gulp.task 'usemin', ['wiredep'], ->
  gulp.src(src.dir.concat(src.global).join('/'))
    .pipe(usemin({jsmin: uglify()}))
    .pipe(gulp.dest(dest.dir))

# compile javascript files from coffeescript
gulp.task 'compile:dev', ->
  gulp.src(src.dir.concat(src.scripts).join('/'))
    .pipe(sourcemaps.init())
    .pipe(plumber())
    .pipe(coffee({bare: true}))
    .pipe(sourcemaps.write())
    .pipe(plumber.stop())
    .pipe(gulp.dest(dest.dir))

# compile scripts and minify for packaging
gulp.task 'compile:package', ->
  gulp.src(src.dir.concat(src.scripts).join('/'))
    .pipe(coffee({bare: true}))
    .pipe(uglify())
    .pipe(gulp.dest(dest.dir))

# build for development
gulp.task 'build', ['clean', 'usemin', 'compile:dev']

# prepare scripts for packaging extension
gulp.task 'package', ['clean', 'usemin', 'compile:package']

# watch for changes
gulp.task 'watch', ->
  gulp.watch(
    [
      src.scripts,
      src.dir.concat(src.global).join('/'),
      'gulpfile.coffee'
    ], ['usemin', 'compile:dev'])
  return

# syncronize project info with bower.json
gulp.task 'sync:bower', ->
  project = require "./project.json"
  gulp.src("./bower.json")
    .pipe(
      jsoneditor(
        (json)->
          json.name = project.name
          json.version = project.version
          json.description = project.description
          json.authors = [project.author]
          json.homepage = project.homepage
          json.license = project.license
          return json
      )
    )
    .pipe(gulp.dest("."))

# syncronize project info with package.json
gulp.task 'sync:package', ->
  project = require "./project.json"
  gulp.src("./package.json")
    .pipe(
      jsoneditor(
        (json)->
          json.name = project.name
          json.version = project.version
          json.description = project.description
          json.author = project.author
          json.homepage = project.homepage
          json.keywords = project.keywords
          return json
      )
    )
    .pipe(gulp.dest("."))

# update related values in Info.plist
gulp.task 'sync:info:plist', ->
  project = require "./project.json"
  gulp.src("./#{dest.dir}/Info.plist")
    .pipe(tap((file)->
      src_file = plist.parse(String(file.contents))
      src_file['CFBundleDisplayName'] = project.name  if src_file['CFBundleDisplayName']?
      src_file['CFBundleShortVersionString'] = project.version  if src_file['CFBundleShortVersionString']?
      src_file['CFBundleVersion'] = project.version  if src_file['CFBundleVersion']?
      src_file['Description'] = project.description if src_file['Description']?
      src_file['Author'] = project.author if src_file['Author']?
      src_file['Website'] = project.homepage if src_file['Website']?

      dest_file = plist.build(src_file, {indent: '\t'})
      file.contents = new Buffer(dest_file)
    ))
    .pipe(intermediate({ container: "plist-config" }, (tmpdir, callback) ->
      cmd = spawn '/usr/libexec/PlistBuddy',
            ['-x', '-c', 'Save', "Info.plist"],
            {cwd: tmpdir}

      cmd.stderr.on 'data', (data) ->
        console.log "An error has occurred: " + data

      cmd.on 'close', callback
    ))
    .pipe(gulp.dest(dest.dir))

# update related values in lgtm-safari-update.plist
gulp.task 'sync:update:plist', ->
  project = require "./project.json"
  gulp.src("./#{src.dir}/lgtm-safari-update.plist")
    .pipe(tap((file)->
      src_file = plist.parse(String(file.contents))
      if src_file['Extension Updates'] and src_file['Extension Updates'][0].length > 0
        src_file['Extension Updates'][0]['CFBundleShortVersionString'] = project.version
        src_file['Extension Updates'][0]['CFBundleVersion'] = project.version
        src_file['Extension Updates'][0]['CFBundleIdentifier'] = project.release.BundleId
        src_file['Extension Updates'][0]['Developer Identifier'] = project.release.DeveloperId
        src_file['Extension Updates'][0]['URL'] = project.release.URL

      dest_file = plist.build(src_file, {indent: '\t'})
      file.contents = new Buffer(dest_file)
    ))
    .pipe(intermediate({ container: "update-plist-config" }, (tmpdir, callback) ->
      cmd = spawn '/usr/libexec/PlistBuddy',
            ['-x', '-c', 'Save', "lgtm-safari-update.plist"],
            {cwd: tmpdir}

      cmd.stderr.on 'data', (data) ->
        console.log "An error has occurred: " + data

      cmd.on 'close', callback
    ))
    .pipe(gulp.dest("./#{src.dir}"))

# sync bower.json, package.json with project.json
gulp.task 'sync:conf', ['sync:bower', 'sync:package', 'sync:info:plist', 'sync:update:plist']

# default task
gulp.task 'default', ['clean','watch']
