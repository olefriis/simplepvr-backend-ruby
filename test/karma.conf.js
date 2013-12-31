basePath = '../';

files = [
  JASMINE,
  JASMINE_ADAPTER,
  'http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js',
  'http://ajax.googleapis.com/ajax/libs/angularjs/1.2.6/angular.min.js',
  'http://ajax.googleapis.com/ajax/libs/angularjs/1.2.6/angular-route.min.js',
  'http://ajax.googleapis.com/ajax/libs/angularjs/1.2.6/angular-resource.min.js',
  'http://ajax.googleapis.com/ajax/libs/angularjs/1.2.6/angular-cookies.min.js',
  'http://ajax.googleapis.com/ajax/libs/angularjs/1.2.6/angular-mocks.js',
  'http://netdna.bootstrapcdn.com/bootstrap/3.0.3/js/bootstrap.min.js',
  'public/js/**/*.js',
  'test/unit/**/*.js'
];

autoWatch = true;

browsers = ['PhantomJS'];

reporters = ['dots']
