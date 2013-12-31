SimplePVR-Ruby-backend
======================
A really, really simple PVR (Personal Video Recorder) system which only supports the
[HDHomeRun network tuners](http://www.silicondust.com/). It's written in Ruby and is highly hackable. If
you don't want to hack it, but just want a solid PVR, no worries: It's dead-simple to use.

SimplePVR does not contain its own player, but currently provides an XBMC plug-in. Apart from that, all
recordings are stored in a simple directory structure (see below for an explanation), so that you can just
point your favorite player to the recordings.

Why?
====
MythTV stopped working for me and my HDHomeRun box in the 0.25 release. Even though MythTV has loads
of merits, I just have no idea what to do when it stops working. I was not in control of my media center.

During the last couple of years, I have spent a substantial amount of time on bugs that suddenly appeared
in MythTV and suddenly went away. I really don't like using systems this brittle. My wife got frustrated
too, which is unfortunate as well...

So I wanted to create a really simple PVR in Ruby, making it possible for others to hack away and have
fun while recording TV shows for the rest of the family.

It's based on the HDHomeRun command-line utility, which means it's:

* built on something that's officially supported by SiliconDust (the makers of HDHomeRun).
* really simple.
* limited to supporting HDHomeRun tuners.

Installation
============
First of all, you need a computer and an HDHomeRun tuner box. On your computer, you need to have the
"hdhomerun_config" tool on the path.

You need Ruby 2.0.0 or newer. When that's in place, simply run this from the command line:

        gem install simple_pvr

It might not always be completely straightforward... simple_pvr uses DataMapper, which in turn relies on
bcrypt-ruby, which compiles some native stuff. So on MacOS, you need to install XCode and its command-line
utilities, or get "make" in some other way. On Linux, it should just work. There's no Windows support.

If you'd like thumbnails for the recorded shows and ability to transcode recordings to WebM (so you can view
them directly in your browser), you need FFMPEG on the command-line. Install it using MacPorts, Homebrew,
"apt-get", or whatever.

Running the server
==================

        pvr_server

First time the server is started, a channel scan on your HDHomeRun is executed, which can take several minutes.
When the server is running, go to [http://localhost:4567](http://localhost:4567). If you want to expose this
URL to the outside world, you'd better supply a username and password:

        username=me password=secret pvr_server

This will secure the application with Basic HTTP Authentication. However, everything is sent in clear text. If
you're worried about your PVR data, you should create an SSL certificate (see
[https://devcenter.heroku.com/articles/ssl-certificate-self](this description), for example) and supply the key
and certificate paths when starting the server:

        username=me password=secret key=server.key cert=server.crt pvr_server

You can also supply the `port` variable, in case you want to expose the server on another port than 4567:

        username=me password=secret key=server.key cert=server.crt port=8443 pvr_server

XMLTV
=====
First you must specify in a YAML file how the channel IDs in your XMLTV file relates to the channel names
that the HDHomeRun has found for you. Create a file called e.g. "channel_mappings.yaml", with lines like this:

        www.ontv.dk/tv/1: DR 1
        www.ontv.dk/tv/2: DR 2

Then read your XMLTV file and the mappings file:

        pvr_xmltv programmes.xmltv channel_mappings.yaml

...and wait a little. You can tell the webserver to update its schedules without restarting the server. This is
done by POST'ing to /api/schedules/reload on the server, e.g.:

        curl -d "" localhost:4567/api/schedules/reload

Or, if you've secured your web server with Basic HTTP Authentication like I told you to, specify username and password:

        curl -d "" -u me:secret localhost:4567/api/schedules/reload

If you've been really good and enabled HTTPS, you should specify that (here we're also running on port 8443, and
we've disabled curl's SSL validation, since we're running with a self-signed certificate...):

        curl -d "" -u me:secret --insecure https://localhost:8443/api/schedules/reload

Recordings
==========
The recordings are laid out like this, from the directory where you ran pvr_server:

* recordings/
  * Borgias/
     * 1331214600/
     * 1333893000/
  * Sports news/
     * 1331387400/
     * 1331473800/
     * 1331560200/
  * ...

The numbers on the directories are simply time stamps. Inside these numbered directories are these files:

* stream.ts: The actual stream. Let VLC or another media player show these for you.
* hdhomerun_save.log: The output from the actual recording command.
* metadata.yml: Recording time, title, channel, etc.

...and a few other files (thumbnails, transcoded version of the recording, etc.).

XBMC Plug-In
============
There's a simple XBMC plug-in for SimplePVR which enables you to easily watch your recordings, see
metadata, and delete watched recordings. See
[the home page](https://github.com/olefriis/simplepvr-frontend-xbmc) for more information.

Future?
=======
This projects needs to be a nice, readable, hackable, tested system. No pull requests are
accepted that violate this.

There is lots of stuff I'd like to do, but I have no deadline - which means that pull
requests are the only means you have for speeding things up. This includes:

* Web interface:
  * "Dashboard" giving "the big picture" of the status of the system (next 5 upcoming recordings,
    last 5 recorded programmes, current status, last couple of errors, whether there are any
    upcoming conflicts, etc.).
  * Better overview of recordings (a flat view).
  * Better overview pages, e.g. "all children programmes", "all movies this week", "tonight's
    programmes", ...
* Setting up schedules defined by a channel, a start time, and a duration (and a name,
  probably), so that the web GUI is usable even without XMLTV.
* Schedule editing: Show which programmes match the edited schedule, to make it easier to create
  a schedule which exactly matches your needs.
* XMLTV import:
  * Let SimplePVR itself fetch XMLTV URLs at specified times of day.
  * Set-up of matching XMLTV IDs to channels could make good use of a GUI.
* Searching for tuners and scanning for channels would be nice through the web GUI.
* Saving with the hdhomerun_config command is done through a shell script, so we can shut it down properly. I'd
  like a simpler solution, but haven't found anything that works both on OS X and Linux.
  [Bluepill](https://github.com/arya/bluepill) seems to do the job, but seems like too big a hammer...

Some features would be cool to have, but I don't have a personal need for them, so they will only
happen if *you* implement them and send me a pull request. Besides, some of them I have no clue how
to implement...

* A logo!
* Some kind of live TV through an XBMC PVR plug-in.
* Plug-ins for other media systems than XBMC.
* Commercial detection.
* Intelligent planning of recordings, taking into account re-runs etc.
* Record multiple programmes on same multiplex, so we are not restricted to only recording two
  programmes at once.
* More complete XMLTV parser.
* Windows support.
* Support for other tuners than HDHomeRun.

Development
===========
You need the following installed:

* Ruby 2.0 or newer.
* [Bundler](http://gembundler.com/).
* [Karma](http://karma-runner.github.com/0.8/index.html).
* [PhantomJS](http://phantomjs.org/) - and the phantomjs executable must be on your path.

When you have cloned the repository, run

        bundle install

When writing a gem, there's no apparent way to run the commands in the bin directory, in our case pvr_server
and pvr_xmltv. (If you know better than I, please let me know!) Therefore, the commands development_server and
development_xmltv are included. Use them as you would pvr_server and pvr_xmltv (see above).

Run all automatic tests like this:

        rake test

(Or just "rake" with no arguments.) This runs the Ruby specs, features, and JavaScript unit tests.

If you want to keep Karma running and let it execute whenever a file changes, run this:

        karma start test/karma.conf.js

The specs currently use Poltergeist to drive PhantomJS, but you can let Selenium drive Firefox instead:

        capybara_driver=selenium rake test:features

To create the gem, make sure that lib/simple_pvr/version.rb is up-to-date, commit everything and run:

        rake build

Then "gem install" the generated gem in the pkg directory, see if everything seems to work (you already ran
the automatic tests, right?), and execute

        rake release

...which will release the gem to rubygems.org.

I'm trying to make Travis CI like SimplePVR, but it's not easy... tests run fine on my own and several
other machines, but fail on Travis: [![Build Status](https://travis-ci.org/olefriis/simplepvr-backend-ruby.png)](https://travis-ci.org/olefriis/simplepvr-backend-ruby)