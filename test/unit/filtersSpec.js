'use strict';

describe('filters', function() {
	beforeEach(module('simplePvr'));
	
	describe('weekdayFilter', function() {
		it('should be blank when there is no weekday filtering', inject(function(filteredWeekdaysFilter) {
			var scheduleWithNoWeekdayFiltering = { filter_by_weekday: false };
			expect(filteredWeekdaysFilter(scheduleWithNoWeekdayFiltering)).toEqual('');
		}));
		
		it('should name a single weekday if only one is selected', inject(function(filteredWeekdaysFilter) {
			var scheduleWithOneWeekdayFiltering = {
				filter_by_weekday: true,
				monday: false,
				tuesday: false,
				wednesday: true,
				thursday: false,
				friday: false,
				saturday: false,
				sunday: false
			};
			expect(filteredWeekdaysFilter(scheduleWithOneWeekdayFiltering)).toEqual('(Wednesdays)');
		}));
		
		it('should name two weekdays if exactly two are selected', inject(function(filteredWeekdaysFilter) {
			var scheduleWithTwoWeekdayFilterings = {
				filter_by_weekday: true,
				monday: true,
				tuesday: false,
				wednesday: true,
				thursday: false,
				friday: false,
				saturday: false,
				sunday: false
			};
			expect(filteredWeekdaysFilter(scheduleWithTwoWeekdayFilterings)).toEqual('(Mondays and Wednesdays)');
		}));
		
		it('should list all weekdays for three and more allowed weekdays', inject(function(filteredWeekdaysFilter) {
			var scheduleWithSeveralWeekdayFilterings = {
				filter_by_weekday: true,
				monday: true,
				tuesday: false,
				wednesday: true,
				thursday: false,
				friday: true,
				saturday: false,
				sunday: false
			};
			expect(filteredWeekdaysFilter(scheduleWithSeveralWeekdayFilterings)).toEqual('(Mondays, Wednesdays, and Fridays)');
			scheduleWithSeveralWeekdayFilterings.saturday = true;
			expect(filteredWeekdaysFilter(scheduleWithSeveralWeekdayFilterings)).toEqual('(Mondays, Wednesdays, Fridays, and Saturdays)');
			scheduleWithSeveralWeekdayFilterings.tuesday = true;
			scheduleWithSeveralWeekdayFilterings.thursday = true;
			scheduleWithSeveralWeekdayFilterings.saturday = true;
			scheduleWithSeveralWeekdayFilterings.sunday = true;
			expect(filteredWeekdaysFilter(scheduleWithSeveralWeekdayFilterings)).toEqual('(Mondays, Tuesdays, Wednesdays, Thursdays, Fridays, Saturdays, and Sundays)')
		}));
	});

	describe('startEarlyEndLateFilter', function() {
		it('should be blank when there is no special start early or end late', inject(function(startEarlyEndLateFilter) {
			var scheduleWithNoStartEarlyOrEndLate = {  };
			expect(startEarlyEndLateFilter(scheduleWithNoStartEarlyOrEndLate)).toEqual('');
		}));

		it('should inform about start early minutes', inject(function(startEarlyEndLateFilter) {
			var scheduleWithStartEarly = { custom_start_early_minutes: 4 };
			expect(startEarlyEndLateFilter(scheduleWithStartEarly)).toEqual('(starts 4 minutes early)');
		}));

		it('should inform about end late minutes', inject(function(startEarlyEndLateFilter) {
			var scheduleWithEndLate = { custom_end_late_minutes: 9 };
			expect(startEarlyEndLateFilter(scheduleWithEndLate)).toEqual('(ends 9 minutes late)');
		}));

		it('should inform about start early and end late minutes', inject(function(startEarlyEndLateFilter) {
			var scheduleWithStartEarlyAndEndLate = { custom_start_early_minutes: 3, custom_end_late_minutes: 8 };
			expect(startEarlyEndLateFilter(scheduleWithStartEarlyAndEndLate)).toEqual('(starts 3 minutes early, ends 8 minutes late)');
		}));
	});

	describe('timeOfDayFilter', function() {
		it('should be blank when there is no filtering on time of day', inject(function(timeOfDayFilter) {
			var scheduleWithNoFilteringOnTimeOfDay = { filter_by_time_of_day: false };
			expect(timeOfDayFilter(scheduleWithNoFilteringOnTimeOfDay)).toEqual('');
		}));

		it('should inform about start time', inject(function(timeOfDayFilter) {
			var scheduleWithStartTime = { filter_by_time_of_day: true, from_time_of_day: '19:00' };
			expect(timeOfDayFilter(scheduleWithStartTime)).toEqual('(after 19:00)');
		}));

		it('should inform about end time', inject(function(timeOfDayFilter) {
			var scheduleWithEndTime = { filter_by_time_of_day: true, to_time_of_day: '9:00' };
			expect(timeOfDayFilter(scheduleWithEndTime)).toEqual('(before 9:00)');
		}));

		it('should inform about start and end time', inject(function(timeOfDayFilter) {
			var scheduleWithStartAndEndTime = { filter_by_time_of_day: true, from_time_of_day: '19:00', to_time_of_day: '22:00' };
			expect(timeOfDayFilter(scheduleWithStartAndEndTime)).toEqual('(between 19:00 and 22:00)');
		}));
	});
    
    describe('diskSpaceFilter', function() {
        var kb = 1024;
        var mb = 1024*1024;
        var gb = 1024*1024*1024;
        var tb = 1024*1024*1024*1024;
        
        it('should handle space below one kilobyte', inject(function(diskSpaceFilter) {
            expect(diskSpaceFilter(0)).toEqual('0 bytes');
            expect(diskSpaceFilter(1)).toEqual('1 byte');
            expect(diskSpaceFilter(2)).toEqual('2 bytes');
            expect(diskSpaceFilter(100)).toEqual('100 bytes');
            expect(diskSpaceFilter(1023)).toEqual('1023 bytes');
        }));
        
        it('should handle space between one kilobyte and one megabyte', inject(function(diskSpaceFilter) {
            expect(diskSpaceFilter(1*kb)).toEqual('1 kilobyte');
            expect(diskSpaceFilter(1*kb + 1)).toEqual('1 kilobyte, 1 byte');
            expect(diskSpaceFilter(2*kb)).toEqual('2 kilobytes');
            expect(diskSpaceFilter(2*kb + 52)).toEqual('2 kilobytes, 52 bytes');
            expect(diskSpaceFilter(1023*kb + 1023)).toEqual('1023 kilobytes, 1023 bytes');
        }));
        
        it('should handle space between one megabyte and one gigabyte', inject(function(diskSpaceFilter) {
            expect(diskSpaceFilter(1*mb)).toEqual('1 megabyte');
            expect(diskSpaceFilter(1*mb + 1*kb + 1)).toEqual('1 megabyte, 1 kilobyte, 1 byte');
            expect(diskSpaceFilter(2*mb)).toEqual('2 megabytes');
            expect(diskSpaceFilter(2*mb + 52*kb + 53)).toEqual('2 megabytes, 52 kilobytes, 53 bytes');
            expect(diskSpaceFilter(1023*mb + 1023)).toEqual('1023 megabytes, 1023 bytes');
            expect(diskSpaceFilter(1023*mb + 1023*kb + 1023)).toEqual('1023 megabytes, 1023 kilobytes, 1023 bytes');
        }));
        
        it('should handle space between one gigabyte and one terabyte', inject(function(diskSpaceFilter) {
            expect(diskSpaceFilter(1*gb)).toEqual('1 gigabyte');
            expect(diskSpaceFilter(1*gb + 1*mb + 1*kb + 1)).toEqual('1 gigabyte, 1 megabyte, 1 kilobyte, 1 byte');
            expect(diskSpaceFilter(2*gb)).toEqual('2 gigabytes');
            expect(diskSpaceFilter(2*gb + 51*mb + 52*kb + 53)).toEqual('2 gigabytes, 51 megabytes, 52 kilobytes, 53 bytes');
            expect(diskSpaceFilter(1023*gb + 1023)).toEqual('1023 gigabytes, 1023 bytes');
            expect(diskSpaceFilter(1023*gb + 1023*mb + 1023*kb + 1023)).toEqual('1023 gigabytes, 1023 megabytes, 1023 kilobytes, 1023 bytes');
        }));
        
        it('does not need to handle bigger sizes than terabytes', inject(function(diskSpaceFilter) {
            expect(diskSpaceFilter(1*tb)).toEqual('1 terabyte');
            expect(diskSpaceFilter(1*tb + 1*gb + 1*mb + 1*kb + 1)).toEqual('1 terabyte, 1 gigabyte, 1 megabyte, 1 kilobyte, 1 byte');
            expect(diskSpaceFilter(2*tb)).toEqual('2 terabytes');
            expect(diskSpaceFilter(2*tb + 50*gb + 51*mb + 52*kb + 53)).toEqual('2 terabytes, 50 gigabytes, 51 megabytes, 52 kilobytes, 53 bytes');
            expect(diskSpaceFilter(1023*tb + 1023)).toEqual('1023 terabytes, 1023 bytes');
            expect(diskSpaceFilter(1023*tb + 1023*gb + 1023*mb + 1023*kb + 1023)).toEqual('1023 terabytes, 1023 gigabytes, 1023 megabytes, 1023 kilobytes, 1023 bytes');

            expect(diskSpaceFilter(1024*tb)).toEqual('1024 terabytes');
        }));
    });
});