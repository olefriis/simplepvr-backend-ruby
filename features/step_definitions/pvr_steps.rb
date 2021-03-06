require 'timeout'
require 'pry'

RSpec::Matchers.define :become do |expected|
  match do |block|
    begin
      Timeout.timeout(Capybara.default_wait_time) do
        sleep(0.1) until expected == block.call
      end
      true
    rescue TimeoutError
      false
    end
  end

  failure_message_for_should do |block|
    "expected that #{block.call} would become #{expected}"
  end

  failure_message_for_should_not do |block|
    "expected that #{block.call} would not become #{expected}"
  end

  description do
    "become #{expected}"
  end
end

Given /the following programmes\:/ do |programme_table|
  programme_table.hashes.each do |programme|
    channel = find_or_create_channel_with_name(programme['channel'] || 'Channel 1')
    air_time = Time.now.advance(days: (programme['day'] || '0').to_i)
    SimplePvr::Model::Programme.add(channel, programme['title'] || '', programme['subtitle'] || '',
      programme['description'] || '', air_time, 60.minutes, ' .23/40. ')
  end
end

Given /the following channels\:/ do |channel_table|
  channel_table.hashes.each do |channel|
    find_or_create_channel_with_name(channel['name'])
  end
end

Given /the following recorded shows:/ do |shows_table|
  recordings_directory = Dir.pwd + '/features/recordings'
  FileUtils.rm_rf(recordings_directory)
  FileUtils.makedirs(recordings_directory)

  shows_table.hashes.each do |show|
    FileUtils.makedirs(recordings_directory + '/' + show['name'])
  end
end

Given /the following recordings:/ do |recordings_table|
  recordings_directory = Dir.pwd + '/features/recordings'

  recordings_table.hashes.each do |recording|
    FileUtils.makedirs(recordings_directory + '/' + recording['name'] + '/' + recording['id'])
  end
end

Given /I have navigated to the week overview for channel "(.*)"/ do |channel|
  visit path_to('the channel overview page')
  fill_in('channel_filter', :with => channel)
  click_link('...')
end

Given /I have navigated to the programme page for "(.*)" on channel "(.*)"/ do |title, channel|
  visit path_to('the channel overview page')
  fill_in('channel_filter', :with => channel)
  click_link('...')
  page.should have_link(title)
  first(:link, title).click
end

Given /I have navigated to the programme page for yesterday's "(.*)" on channel "(.*)"/ do |title, channel|
  visit path_to('the channel overview page')
  fill_in('channel_filter', :with => channel)
  click_link('...')
  click_link('<<')
  click_link(title)
end

Given /I choose to record just this programme/ do
  choose_to_record('Record just this programme')
end

Given /I choose to record the programme on this channel/ do
  choose_to_record('Record on this channel')
end

Given /I choose to record the programme on any channel/ do
  choose_to_record('Record on any channel')
end

When /I enter "(.*)" in the programme search field/ do |query|
  fill_in('programme-search-query', :with => query)
end

When /I search for programmes with title "(.*)"/ do |query|
  fill_in('programme-search-query', :with => query)
  click_button('Search')
end

When /I delete the first schedule/ do
  page.should have_button('Delete')
  first(:button, 'Delete').click
end

When /I choose not to record the first scheduled show/ do
  page.should have_link('Do not record this specific show')
  first(:link, 'Do not record this specific show').click
end

Then /I should see the programme title suggestion "(.*)"/ do |suggestion|
  page.should have_text(text)
end

When /I see the details for show "(.*)"/ do |show_name|
  div = find(:xpath, "//h2[text()='#{show_name}']").find(:xpath, '..')
  within(div) do
    click_on('Episodes')
  end
end

Then /I should see (\d*) recordings/ do |number_of_recordings|
  expect { page.all(:xpath, "//button[text()='Delete recording']").length }.to become(number_of_recordings.to_i)
end

Then /I should see "(.*)" in the page contents/ do |text|
  within('#contents') do
    page.should have_text(text)
  end
end

Then /I should see the schedule "(.*)"/ do |text|
  within('#schedules') do
    page.should have_text(text)
  end
end

Then /I should see the timed schedule "(.*)"/ do |text|
  within('#schedules') do
    page.should have_content(/#{text} .* \d+, \d{4} at \d?\d:\d\d/)
  end
end

Then /I should not see the schedule "(.*)"/ do |text|
  within('#schedules') do
    page.should_not have_text(text)
  end
end

Then /I should not see the button "(.*)"/ do |text|
  page.should_not have_button(text)
end

Then /there should be (\d*) upcoming recordings?/ do |upcoming_recordings|
  expect { page.find('#upcoming_recordings').all('h2').length }.to become(upcoming_recordings.to_i)
end

Then /^there should be a conflict$/ do
  page.should have_text('(Conflicting)')
end

Then /^there should be no conflicts$/ do
  page.should_not have_text('(Conflicting)')
end

Then /I wait (\d*) seconds/ do |seconds|
  sleep seconds.to_i
end

Then /I start the debugger/ do
  binding.pry
end

def find_or_create_channel_with_name(name)
  channel = SimplePvr::Model::Channel.first(name: name)
  channel ? channel : SimplePvr::Model::Channel.add(name, 0, 0)
end

def choose_to_record(button_text)
  click_button(button_text)
  page.should have_text('This programme is being recorded')
end
