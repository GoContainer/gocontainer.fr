// Requis
var gulp = require('gulp');

// Include plugins
var plugins = require('gulp-load-plugins')(); // tous les plugins de package.json
var imagemin = require('gulp-imagemin');
var concat = require('gulp-concat');

gulp.task('js', function () {
    return gulp.src('themes/gocontainer/src/js/*.js')
        .pipe(concat('gocontainer.js'))
        .pipe(gulp.dest('themes/gocontainer/static/js/'));
});

gulp.task('css', function () {
    return gulp.src('themes/gocontainer/src/css/*.css')
        .pipe(concat('gocontainer.css'))
        .pipe(gulp.dest('themes/gocontainer/static/css/'));
});

gulp.task('build', ['css', 'js']);


// Tâche par défaut
gulp.task('default', ['build']);
