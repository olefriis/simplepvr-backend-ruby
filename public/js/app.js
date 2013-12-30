'use strict';

angular.module('simplePvr', ['ngRoute', 'ngCookies', 'simplePvrServices', 'simplePvrFilters', 'http-auth-interceptor']).
directive('loginDialog', function($timeout) {
   return {
       templateUrl: '/app/templates/loginDialog.html',
       restrict: 'E',
       replace: true,
       controller: CredentialsController,
       link: function(scope, element, attributes, controller) {
           var isShowing = false;
           var isShown = false;
           
           element.on('shown.bs.modal', function(e) {
               isShowing = false;
               isShown = true;
               element.find('#userName').focus();
           });
           
           scope.$on('event:auth-loginRequired', function() {
               if (isShowing || isShown) {
                   return;
               }
               // If we're in the process of hiding the modal, we need to wait for
               // all CSS animations to complete before showing the modal again.
               // Otherwise, we might end up with an invisible modal, making the whole
               // view rather unusable. I've been unable to control the transitions
               // between "showing", "shown", "hiding", and "hidden" tightly using
               // JQuery notifications without collecting more and more modal backdrops
               // in the DOM, so the dirty solution here is to simply wait a second
               // before showing the log-in dialog.
               isShowing = true;
               $timeout(function() {
                   element.modal('show');
               }, 1000);
           });

           scope.$on('event:auth-loginConfirmed', function() {
               isShown = false;
               element.modal('hide');
               scope.credentials.password = '';
           });
       }
   } 
}).
directive('titleSearch', function($cookieStore) {
    return {
        templateUrl: '/app/templates/titleSearch.html',
        restrict: 'E',
		replace: true,
		controller: SearchProgrammesCtrl,
		link: function(scope, element, attributes, controller) {
			var inputField = element.find('input');
			inputField.typeahead({
				remote: {
		            url: '/api/programmes/title_search?query=%QUERY',
                    beforeSend: function(jqXhr, settings) {
                        var credentials = $cookieStore.get('basicCredentials');
                        if (credentials) {
                            jqXhr.setRequestHeader('Authorization', 'Basic ' + credentials);
                        }
                    }
				}
			});
			var updateTitle = function() {
				scope.$apply(function() {
					scope.title = inputField.val();
				});
			};
			inputField.change(updateTitle);
			inputField.on('typeahead:autocompleted', updateTitle);
		}
	};
}).
directive('navbarItem', function($location) {
	return {
		template: '<li><a ng-href="{{route}}" ng-transclude></a></li>',
		restrict: 'E',
		transclude: true,
		replace: true,
		scope: { route:'@route' },
		link: function(scope, element, attributes, controller) {
			scope.$on('$routeChangeSuccess', function() {
				var path = $location.path();
				var isSamePath = path == scope.route;
				var isSubpath = path.indexOf(scope.route + '/') == 0;
				if (isSamePath || isSubpath) {
					element.addClass('active');
				} else {
					element.removeClass('active');
				}
			});
		}
	};
}).
config(function($routeProvider, $locationProvider, $httpProvider) {
    $httpProvider.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
    
    $locationProvider.html5Mode(true).hashPrefix('');

	$routeProvider.
	when('/schedules', {
		templateUrl: '/app/partials/schedules.html',
		controller: SchedulesCtrl
	}).
	when('/schedules/:scheduleId', {
		templateUrl: '/app/partials/schedule.html',
		controller: ScheduleCtrl
	}).
	when('/channels', {
		templateUrl: '/app/partials/channels.html',
		controller: ChannelsCtrl
	}).
	when('/channels/:channelId/programmeListings/:date', {
		templateUrl: '/app/partials/programmeListing.html',
		controller: ProgrammeListingCtrl
	}).
	when('/programmes/:programmeId', {
		templateUrl: '/app/partials/programme.html',
		controller: ProgrammeCtrl
	}).
	when('/shows', {
		templateUrl: '/app/partials/shows.html',
		controller: ShowsCtrl
	}).
	when('/shows/:showId', {
		templateUrl: '/app/partials/show.html',
		controller: ShowCtrl
	}).
	when('/search', {
		templateUrl: '/app/partials/search.html',
		controller: SearchCtrl
	}).
	when('/status', {
		templateUrl: '/app/partials/status.html',
		controller: StatusCtrl
	}).
	when('/about', {
		templateUrl: '/app/partials/about.html'
	}).
	otherwise({
		redirectTo: '/schedules'
	});
});
