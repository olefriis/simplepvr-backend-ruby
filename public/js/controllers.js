'use strict';

function LoginController($scope, $http, $cookieStore, authService) {
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
    
    $scope.credentials = { userName: '', password: '' };
    
    var basicCredentials = $cookieStore.get('basicCredentials');
    if (basicCredentials) {
        $http.defaults.headers.common.Authorization = 'Basic ' + basicCredentials;
    }
    
    $scope.submit = function() {
        var encodedUserNameAndPassword = encodeBase64($scope.credentials.userName + ':' + $scope.credentials.password);
        $cookieStore.put('basicCredentials', encodedUserNameAndPassword);
        $http.defaults.headers.common.Authorization = 'Basic ' + encodedUserNameAndPassword;

        // Maybe we should have a REST service for testing the user name and password, but for now
        // it's OK to just re-open the log-in dialog if the entered credentials are wrong.
        authService.loginConfirmed();
    }
}

function SchedulesCtrl($scope, $http, Schedule, UpcomingRecording, Channel) {
	var updateView = function() {
		$scope.schedules = Schedule.query();
		$scope.upcomingRecordings = UpcomingRecording.query();
		$scope.newSchedule = { title: null, channelId: 0 }
	}

	$scope.channels = Channel.query();
	updateView();
	
	$scope.createSchedule = function() {
		var schedule = new Schedule({ title: $scope.newSchedule.title, channel_id: $scope.newSchedule.channelId })
		schedule.$save(updateView);
	}
	
	$scope.deleteSchedule = function(schedule) {
		schedule.$delete(updateView);
	}
	
	$scope.excludeRecording = function(recording) {
		$http.post('/api/programmes/' + recording.programme_id + '/exclude').success(updateView);
	}
}

function ScheduleCtrl($scope, $routeParams, $location, Schedule, Channel) {
	$scope.channels = Channel.query(function() {
		$scope.schedule = Schedule.get({id: $routeParams.scheduleId}, function() {
			for (var i=0; i<$scope.channels.length; i++) {
				var channel = $scope.channels[i]
				if ($scope.schedule.channel && channel.id === $scope.schedule.channel.id) {
					$scope.channel = channel;
				}
			}
		});
	});
	
	$scope.update = function() {
		$scope.schedule.channel = $scope.channel;
		$scope.schedule.$save(function() { $location.path('/schedules'); });
	}
}

function ChannelsCtrl($scope, $http, Channel) {
	$scope.channels = Channel.query();
	$scope.showHiddenChannels = false;
	
	$scope.classForProgrammeLine = function(programme) {
		if (programme == null) {
			return '';
		}
		return programme.is_conflicting ? 'error' : (programme.is_scheduled ? 'success' : '');
	}
	$scope.hideChannel = function(channel) {
		// I wish Angular could let me define this operation on the Channel object
		$http.post('/api/channels/' + channel.id + '/hide').success(function() { channel.$get(); });
	}
	$scope.showChannel = function(channel) {
		// I wish Angular could let me define this operation on the Channel object
		$http.post('/api/channels/' + channel.id + '/show').success(function() { channel.$get(); });
	}
	$scope.shouldShowChannel = function(channel) {
		return $scope.showHiddenChannels || !channel.hidden;
	}
}

function ProgrammeListingCtrl($scope, $routeParams, ProgrammeListing) {
	$scope.channelId = $routeParams.channelId;
	$scope.date = $routeParams.date;
	$scope.programmeListing = ProgrammeListing.get({channelId: $scope.channelId, date: $scope.date});
	
	$scope.classForProgrammeLine = function(programme) {
		return programme.is_conflicting ? 'error' : (programme.is_scheduled ? 'success' : '');
	}
}

function ProgrammeCtrl($scope, $routeParams, $http, Programme) {
	var loadProgramme = function() {
		$scope.programme = Programme.get({id: $routeParams.programmeId});
	}
	var post = function(url) {
		$http.post(url).success(loadProgramme);
	}
	
	$scope.recordOnThisChannel = function() {
		// I wish Angular could let me define this operation on the Programme object
		post('/api/programmes/' + $scope.programme.id + '/record_on_this_channel');
	}
	$scope.recordOnAnyChannel = function() {
		// I wish Angular could let me define this operation on the Programme object
		post('/api/programmes/' + $scope.programme.id + '/record_on_any_channel');
	}
	$scope.recordJustThisProgramme = function() {
		// I wish Angular could let me define this operation on the Programme object
		post('/api/programmes/' + $scope.programme.id + '/record_just_this_programme');
	}

	loadProgramme();
}

function ShowsCtrl($scope, $http, Show) {
	var loadShows = function() {
		$scope.shows = Show.query();
	}
	
	$scope.deleteEpisodes = function(show) {
		if (confirm("Really delete all episodes of\n" + show.name + "\n?")) {
			show.$delete(loadShows);
		}
	}
	
	loadShows();
}

function ShowCtrl($scope, $routeParams, $http, Show, Recording) {
	var loadRecordings = function() {
		$scope.recordings = Recording.query({showId: $routeParams.showId});
	}
	
	$scope.deleteRecording = function(recording) {
		if (confirm("Really delete this recording of show\n" + $scope.show.name + "\n?")) {
			recording.$delete(loadRecordings);
		}
	}

	$scope.startTranscoding = function(recording) {
		// I wish Angular could let me define this operation on the Programme object
		$http.post('/api/shows/' + $routeParams.showId + '/recordings/' + recording.id + '/transcode').success(loadRecordings);
	}

	$scope.show = Show.get({id: $routeParams.showId});
	loadRecordings();
}

function SearchProgrammesCtrl($scope, $http, $location) {
	$scope.updater = function(item) {
		$scope.$apply(function() {
			$scope.title = item;
		});
		return item;
	}
	
	$scope.search = function() {
		$location.path('/search').search({query: $scope.title});
	}
}

function SearchCtrl($scope, $routeParams, $http) {
	$scope.query = $routeParams.query;
	$http.get('/api/programmes/search', {params: {query: $scope.query}}).success(function(result) {
		$scope.result = result;
	});
}

function StatusCtrl($scope, Status) {
	$scope.status = Status.get();
}