gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
del = require 'del'
plumber = require 'gulp-plumber'
rev = require 'gulp-rev'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'
usemin = require 'gulp-usemin2'
wiredep = require('wiredep').stream

src = {
  dir: ['src'],
  scripts: ['**/*.coffee'],
  global: ['global.html']
}

dest = {
  dir: 'lgtm.safariextension'
}

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
  return gulp.src(src.dir.concat(src.global).join('/'))
    .pipe(usemin({jsmin: uglify()}))
    .pipe(gulp.dest(dest.dir))

# compile javascript files from coffeescript
gulp.task 'compile:dev', ->
  return gulp.src(src.dir.concat(src.scripts).join('/'))
  .pipe(sourcemaps.init())
  .pipe(plumber())
  .pipe(coffee({bare: true}))
  .pipe(sourcemaps.write())
  .pipe(plumber.stop())
  .pipe(gulp.dest(dest.dir))

# compile scripts and minify for packaging
gulp.task 'compile:package', ->
  return gulp.src(src.scripts)
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

# default task
gulp.task 'default', ['clean','watch']
