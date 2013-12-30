'use strict';

angular.module('simplePvrServices', ['ngResource']).
factory('UpcomingRecording', function($resource) {
	return $resource('/api/upcoming_recordings/:id');
}).
factory('Schedule', function($resource) {
	return $resource('/api/schedules/:id', {id: '@id'});
}).
factory('Channel', function($resource) {
	return $resource('/api/channels/:id', {id: '@id'});
}).
factory('ProgrammeListing', function($resource) {
	return $resource('/api/channels/:channelId/programme_listings/:date');
}).
factory('Programme', function($resource) {
	return $resource('/api/programmes/:id');
}).
factory('Show', function($resource) {
	return $resource('/api/shows/:id', {id: '@id'});
}).
factory('Recording', function($resource) {
	return $resource('/api/shows/:showId/recordings/:recordingId', {showId: '@show_id', recordingId: '@id'});
}).
factory('Status', function($resource) {
	return $resource('/api/status');
}).
service('loginService', function($http, $cookieStore, authService) {
    // Taken from http://wemadeyoulook.at/en/blog/implementing-basic-http-authentication-http-requests-angular/
    function encodeBase64(input) {
        var keyStr = 'ABCDEFGHIJKLMNOP' +
            'QRSTUVWXYZabcdef' +
            'ghijklmnopqrstuv' +
            'wxyz0123456789+/' +
            '=';
            
        var output = '';
        var chr1, chr2, chr3 = '';
        var enc1, enc2, enc3, enc4 = '';
        var i = 0;

        do {
            chr1 = input.charCodeAt(i++);
            chr2 = input.charCodeAt(i++);
            chr3 = input.charCodeAt(i++);

            enc1 = chr1 >> 2;
            enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
            enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
            enc4 = chr3 & 63;

            if (isNaN(chr2)) {
                enc3 = enc4 = 64;
            } else if (isNaN(chr3)) {
                enc4 = 64;
            }

            output = output +
                keyStr.charAt(enc1) +
                keyStr.charAt(enc2) +
                keyStr.charAt(enc3) +
                keyStr.charAt(enc4);
            chr1 = chr2 = chr3 = '';
            enc1 = enc2 = enc3 = enc4 = '';
        } while (i < input.length);

        return output;
    }

    var basicCredentials = $cookieStore.get('basicCredentials');
    if (basicCredentials) {
        $http.defaults.headers.common['Authorization'] = 'Basic ' + basicCredentials;
    }

    return {
        setUserNameAndPassword: function(userName, password) {
            var encodedUserNameAndPassword = encodeBase64(userName + ':' + password);
            $cookieStore.put('basicCredentials', encodedUserNameAndPassword);
            
            $http.defaults.headers.common['Authorization'] = 'Basic ' + encodedUserNameAndPassword;
            authService.loginConfirmed();
        },
        isLoggedIn: function() {
            return $cookieStore.get('basicCredentials') !== undefined;
        },
        logOut: function() {
            $cookieStore.remove('basicCredentials');
            delete $http.defaults.headers.common['Authorization'];
        }
    }
});
