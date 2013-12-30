basePath = '../';

files = [
  JASMINE,
  JASMINE_ADAPTER,
  'public/js/jquery/jquery.min.js',
  'http://ajax.googleapis.com/ajax/libs/angularjs/1.2.6/angular.min.js',
  'http://ajax.googleapis.com/ajax/libs/angularjs/1.2.6/angular-route.min.js',
  'http://ajax.googleapis.com/ajax/libs/angularjs/1.2.6/angular-resource.min.js',
  'http://ajax.googleapis.com/ajax/libs/angularjs/1.2.6/angular-mocks.js',
  'public/js/**/*.js',
  'test/unit/**/*.js'
];

autoWatch = true;

browsers = ['PhantomJS'];

reporters = ['dots']
