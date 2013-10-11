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

	describe('startEarlyEndLateFilter ', function() {
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

	describe('timeOfDayFilter ', function() {
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
});