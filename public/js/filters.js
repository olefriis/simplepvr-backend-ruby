'use strict';

angular.module('simplePvrFilters', []).
filter('formatEpisode', function() {
    return function(episodeNum) {
        return episodeNum ? episodeNum.replace(' .', '').replace('. ', '') : '';
    }
}).
filter('filteredWeekdays', function() {
	return function(schedule) {
		if (!schedule.filter_by_weekday) {
			return '';
		}
		
		var selectedWeekdays = [];
		if (schedule.monday) selectedWeekdays.push('Mondays');
		if (schedule.tuesday) selectedWeekdays.push('Tuesdays');
		if (schedule.wednesday) selectedWeekdays.push('Wednesdays');
		if (schedule.thursday) selectedWeekdays.push('Thursdays');
		if (schedule.friday) selectedWeekdays.push('Fridays');
		if (schedule.saturday) selectedWeekdays.push('Saturdays');
		if (schedule.sunday) selectedWeekdays.push('Sundays');

		var days = '';
		if (selectedWeekdays.length == 0) {
			return ''
		} else if (selectedWeekdays.length == 1) {
			days = selectedWeekdays[0];
		} else if (selectedWeekdays.length == 2) {
			days = selectedWeekdays[0] + ' and ' + selectedWeekdays[1];
		} else {
			for (var i=0; i<selectedWeekdays.length - 1; i++) {
				days += selectedWeekdays[i] + ', ';
			}
			days += 'and ' + selectedWeekdays[selectedWeekdays.length - 1];
		}
		return '(' + days + ')';
	}
}).
filter('timeOfDay', function() {
	return function(schedule) {
		if (!schedule.filter_by_time_of_day) {
			return '';
		}
		if (schedule.from_time_of_day && schedule.to_time_of_day) {
			return '(between ' + schedule.from_time_of_day + ' and ' + schedule.to_time_of_day + ')';
		}
		if (schedule.from_time_of_day) {
			return '(after ' + schedule.from_time_of_day + ')';
		}
		if (schedule.to_time_of_day) {
			return '(before ' + schedule.to_time_of_day + ')';
		}
	}
}).
filter('diskSize', function() {
    function sizeAsString(size, singular, plural) {
        if (size == 1) {
            return '1 ' + singular;
        }
        return size + ' ' + plural;
    }
    
    return function(size) {
        var kilobyte = 1024;
        var megabyte = 1024*1024;
        var gigabyte = 1024*1024*1024;
        var terabyte = 1024*1024*1024*1024;

        var sizes = [];
        if (size >= terabyte) {
            var sizeInTerabytes = Math.floor(size / terabyte);
            sizes.push(sizeAsString(sizeInTerabytes, 'terabyte', 'terabytes'));
            size -= sizeInTerabytes * terabyte;
        }
        if (size >= gigabyte) {
            var sizeInGigabytes = Math.floor(size / gigabyte);
            sizes.push(sizeAsString(sizeInGigabytes, 'gigabyte', 'gigabytes'));
            size -= sizeInGigabytes * gigabyte;
        }
        if (size >= megabyte) {
            var sizeInMegabytes = Math.floor(size / megabyte);
            sizes.push(sizeAsString(sizeInMegabytes, 'megabyte', 'megabytes'));
            size -= sizeInMegabytes * megabyte;
        }
        if (size >= kilobyte) {
            var sizeInKilobytes = Math.floor(size / kilobyte);
            sizes.push(sizeAsString(sizeInKilobytes, 'kilobyte', 'kilobytes'));
            size -= sizeInKilobytes * kilobyte;
        }
        if (size > 0 || sizes.length == 0) {
            sizes.push(sizeAsString(size, 'byte', 'bytes'));
        }
        
        return sizes.join(', ');
    }
}).
filter('startEarlyEndLate', function() {
	return function(schedule) {
		var sentences = [];
		if (schedule.custom_start_early_minutes) {
			sentences.push('starts ' + schedule.custom_start_early_minutes + ' minutes early');
		}
		if (schedule.custom_end_late_minutes) {
			sentences.push('ends ' + schedule.custom_end_late_minutes + ' minutes late');
		}
		if (sentences.length > 0) {
			return '(' + sentences.join(', ') + ')';
		}
		return '';
	}
});