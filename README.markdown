# Flogiston-cms

 - github repo: [http://github.com/flogic/flogiston-cms] [github]
 - pivotal tracker project (stories): [http://www.pivotaltracker.com/projects/10392] [pivotal]

[github]: http://github.com/flogic/flogiston-cms
[pivotal]: http://www.pivotaltracker.com/projects/10392

## Flogiston

In 2008-2009 we noticed a growing problem in the Rails ecosystem.  There are a certain set of simple features that many web applications need, including basic content management, weblog functionality, commenting, file uploads, authentication, permissioning, etc.  Above this base set of features, most applications then tend to diverge into custom functionality.

As custom software developers we often found ourselves in a position where a customer was seeking for some custom application to be developed, and, by the way, can we also get the ability to edit pages and do blog posts and have people comment on stuff?

While there are a number of tools available to do larger systems (e.g., social networking tools like lovdbyless and community engine), in large part these tools are overkill for custom applications which only use a subset of those features.

We sometimes need to add CMS features or blogging functionality onto an existing Rails app.  Or we're asked to upgrade an existing blog to include custom functionality.  Typically this would mean taking a wordpress PHP site, converting it quickly to a Rails blog and then adding the custom functionality.

Unfortunately the Rails CMS landscape, the Rails blogging landscape, the tools for commenting, uploading, etc., leave much to be desired when faced with our usage model.

The tools available are either too large (e.g., mephisto, typo) and _become_ the application -- implying that you have to work around the tool, and be a slave to its upgrade schedule, refactorings, and community politics -- or the tools are untested, or they are dead on the vine, or they are sometimes just crazily architected, or they ask that you embed your application as a freakin' plugin into the tool (really?  Really??)

What we were looking for are small single-purpose tools that can be dropped into existing applications and which then only do the one thing needed, and don't do a bunch of other crazy stuff.  When we noticed that prominent developers in the Rails community (some who had even been involved in high profile cms/blogging/etc. projects) were asking for recommendations on what to use for CMS/blog/etc. functionality in apps, we figured we might as well try to solve the problem.

Authentication is mostly taken care of (restful_auth, authlogic, clearance, etc.) and so we are ok enough there, at least for the time being.  Uploading is probably mostly taken care of, though there seems to be a real predilection towards requiring ImageMagick even if it's only PDFs and Word docs being uploaded.  We decided to start with basic content management, then to do blogging, and then see what we're being asked to do most often next.

## Flogiston-cms

So, flogiston-cms is the content management flogiston tidbit.  The ideas here are dead simple:

 - You should be able to install flogiston-cms as a plugin into an existing application and suddenly have the ability for "administrators" (whatever that means in your application) to create, edit, and delete arbitrary "pages", visible on the public part of the application.  Admin wants to make an "about" page, a "contact us" page, and a "home" page?  They log in, create the pages, attach them to URLs, and they're done.

 - You should be able to install flogiston-cms as a standalone rails app that just does CMS stuff and you can add more controllers and actions, etc.  This isn't necessarily the best way to go (as things might get tricky when you want to upgrade flogiston-cms functionality in the future), but it's in the realm of possibilities.  Also, we like to use this mode when we're testing flogiston-cms.

 - Admins should be able to create a page at any url.  "/foo", "/bar/baz".

 - Admins should be able to even create a page at the root url ("/").

 - But, if the requested page is going to collide with a route taken up by a controller in the system, the CMS should be smart enough to stop that from happening ... or if the controller comes later, to flag pages which are newly in conflict.

 - The admin functionality should dovetail easily with any existing admin functionality on the site.

 - Ideally upgrades should be simple, at least if you're using the plugin version of the CMS.

 - The whole thing should be written BDD, spec-first.  Dammit.

 - And, really, the CMS shouldn't do a hell of a lot more than that.

To get the plugin stuff working right we're using the new and improved (aka, non-weird and now efficient) Rails "engines" support in Rails 2.3.  Which means your app needs to be running under Rails 2.3 to install flogiston-cms as a plugin.  Them's the breaks.  Come live with us here in the future.


## Using Flogiston-cms as a plugin

### Requirements

  - Requires Rails 2.3 or later.
  - Requires rspec, rspec-rails, and mocha to run tests.

### Installation

    % script/plugin install git://github.com/flogic/flogiston-cms.git
    % rake gems:install
    % rake gems:unpack
    % rake gems:build
    % rake db:migrate

### Living with it

Flogiston-cms comes with some migrations, which get copied up to the application's db/migrate directory and get run when you do "rake db:migrate".  On the off chance you already have a pages table then, well, wtf dude?

Also, flogiston-cms has its own Sass-based stylesheets, which also get copied up for use in your application.  These are all named in such a way that they are not only obviously from flogiston-cms, but also won't collide with any of your stylesheet filenames unless you are extremely unlucky or being somewhat perverse.

There is an admin layout in the plugin which uses the flogiston-cms stylesheets.  If you have an admin layout in your application then your admin layout overrides flogiston-cms' layout and everything is groovy.  Except for the fact that you won't have links to the page-related functionality from the flogiston-cms admin layout.  Which kinda makes sense, but means you need to include that logic in your admin layout if you want people to be able to manage pages.  Just sayin'.

## Using Flogiston-cms as a standalone app

### Requirements

  - Requires rspec, rspec-rails, and mocha to run tests.

### Installation

    % git clone git://github.com/flogic/flogiston-cms.git
    % rake gems:install
    % rake gems:unpack
    % rake gems:build
    % rake db:migrate

### Living with it

It's pretty chill, as everything's a Rails app.  Upgrades are probably going to be a bitch though.  You're aware of that, right?  Good.  Call us, we do rescues of bitched-up apps.


*Copyright (c) 2009 Flawed Logic, OG Consulting, Kevin Barnes, Rick Bradley, Yossef Mendelssohn, released under the MIT license*
