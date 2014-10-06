gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
clean = require 'gulp-clean'
rev = require 'gulp-rev'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'
usemin = require 'gulp-usemin'
minifyHtml = require 'gulp-minify-html'
wiredep = require('wiredep').stream

src = {
  dir: ['src'],
  scripts: ['**/*.coffee'],
  global: ['global.html']
}

dest = {
  dir: ['lgtm.safariextension']
}

# cleanup compiled javascript files
gulp.task 'clean', ->
  return gulp.src(dest.dir.concat(['**/*.js']).join('/'), {read: false})
    .pipe(clean())

# inject bower dependencies
gulp.task 'wiredep', ->
  gulp.src(src.dir.concat(src.global).join('/'))
    .pipe(wiredep({
      directory: './bower_components',
      bowerJson: require('./bower.json')
    }))
    .pipe(gulp.dest(src.dir.concat('/').join('')))

# merge all dependencies into single file
gulp.task 'usemin', ->
  gulp.src(src.dir.concat(src.global).join('/'))
    .pipe(usemin({
      html: [minifyHtml({empty: true})],
      js: [uglify(), rev()]
    }))
    .pipe(gulp.dest(dest.dir.pop()))

# compile javascript files from coffeescript
gulp.task 'compile', ['clean', 'wiredep'], ->
  return gulp.src(src.scripts)
  .pipe(sourcemaps.init())
  .pipe(coffee())
  .pipe(sourcemaps.write())
  .pipe(gulp.dest(dest.dir.pop()))

# compile scripts and minify for packaging
gulp.task 'package', ['clean', 'wiredep'], ->
  return gulp.src(src.scripts)
  .pipe(coffee())
  .pipe(uglify())
  .pipe(gulp.dest(dest.dir.pop()))

# watch for changes
gulp.task 'watch', ->
  gulp.watch(src.scripts, ['compile'])

# default task
gulp.task 'default', ['watch', 'compile']
