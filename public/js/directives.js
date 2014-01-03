'use strict';

angular.module('simplePvrDirectives', []).
directive('loginDialog', function($timeout) {
   return {
       templateUrl: '/app/templates/loginDialog.html',
       restrict: 'E',
       replace: true,
       controller: CredentialsController,
       link: function(scope, element, attributes, controller) {
           var isShowing = false;
           
           element.on('shown.bs.modal', function(e) {
               element.find('#userName').focus();
           });

           scope.$on('event:auth-loginRequired', function() {
               if (isShowing) {
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
                   isShowing = false;
               }, 1000);
           });

           scope.$on('event:auth-loginConfirmed', function() {
               element.modal('hide');
               scope.credentials.password = '';
           });
       }
   } 
}).
directive('logoutLink', function() {
   return {
       templateUrl: '/app/templates/logoutLink.html',
       restrict: 'E',
       replace: true,
       controller: LoginController
   } 
}).
directive('titleSearch', function(loginService) {
    return {
        templateUrl: '/app/templates/titleSearch.html',
        restrict: 'E',
        replace: true,
        controller: SearchProgrammesCtrl,
        link: function(scope, element, attributes, controller) {
            var inputField = element.find('input');
            inputField.typeahead({
                remote: '/api/programmes/title_search?query=%QUERY'
            });

            var updateTitle = function() {
                scope.$apply(function() {
                    scope.title = inputField.val();
                });
            };
            var updateTitleAndPerformSearch = function() {
                scope.$apply(function() {
                    scope.title = inputField.val();
                    scope.search();
                })
            }

            inputField.change(updateTitle);
            inputField.on('typeahead:autocompleted', updateTitle);
            inputField.on('typeahead:selected', updateTitleAndPerformSearch);
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
});