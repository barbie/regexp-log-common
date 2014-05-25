package Regexp::Log::Common;

use warnings;
use strict;
use base qw( Regexp::Log );
use vars qw( $VERSION %DEFAULT %FORMAT %REGEXP );

$VERSION = 0.07;

=head1 NAME

Regexp::Log::Common - A regular expression parser for the Common Log Format

=head1 SYNOPSIS

    my $foo = Regexp::Log::Common->new(
        format  => '%date %request',
        capture => [qw( ts request )],
    );

    # the format() and capture() methods can be used to set or get
    $foo->format('%date %request %status %bytes');
    $foo->capture(qw( ts req ));

    # this is necessary to know in which order
    # we will receive the captured fields from the regexp
    my @fields = $foo->capture;

    # the all-powerful capturing regexp :-)
    my $re = $foo->regexp;

    while (<>) {
        my %data;
        @data{@fields} = /$re/;    # no need for /o, it's a compiled regexp

        # now munge the fields
        ...
    }

=head1 DESCRIPTION

Regexp::Log::Common uses Regexp::Log as a base class, to generate regular
expressions for performing the usual data munging tasks on log files that
cannot be simply split().

This specific module enables the computation of regular expressions for
parsing the log files created using the Common Log Format. An example of
this format are the logs generated by the httpd web server using the
keyword 'common'.

The module also allows for the use of the Extended Common Log Format.

For more information on how to use this module, please see Regexp::Log.

=head1 ABSTRACT

Enables simple parsing of log files created using the Common Log Format or the
Extended Common Log Format, such as the logs generated by the httpd/Apache web
server using the keyword 'common'.

=cut

# default values
%DEFAULT = (
	format  => '%host %rfc %authuser %date %request %status %bytes %referer %useragent',
	capture => [ 'host', 'rfc', 'authuser', 'date', 'ts', 'request', 'req',
				 'status', 'bytes', 'referer', 'ref', 'useragent', 'ua' ],
);

# predefined format strings
%FORMAT = (
	':default'  => '%host %rfc %authuser %date %request %status %bytes',
	':common'   => '%host %rfc %authuser %date %request %status %bytes',
	':extended' => '%host %rfc %authuser %date %request %status %bytes %referer %useragent',
);

# the regexps that match the various fields
%REGEXP = (
#	'%host' => '(?#=host)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?#!host)',
													# IPv4 only
	'%host' => '(?#=host)\S+(?#!host)',				# numeric or name of remote host
	'%rfc' => '(?#=rfc).*?(?#!rfc)',				# rfc931
	'%authuser' => '(?#=authuser).*?(?#!authuser)',	# authuser
	'%date' => '(?#=date)\[(?#=ts)\d{2}\/\w{3}\/\d{4}(?::\d{2}){3} [-+]\d{4}(?#!ts)\](?#!date)',
													# [date] (see note)
	'%request' => '(?#=request)\"(?#=req).*?(?#!req)\"(?#!request)',
													# "request"
	'%status' => '(?#=status)\d+(?#!status)',		# status
	'%bytes' => '(?#=bytes)-|\d+(?#!bytes)',		# bytes
	'%referer' => '(?#=referer)\"(?#=ref).*?(?#!ref)\"(?#!referer)',
													# "referer"
	'%useragent' => '(?#=useragent)\"(?#=ua).*?(?#!ua)\"(?#!useragent)',
													# "user_agent"
);

# note: date is in the format [01/Jan/1997:13:07:21 -0600]

1;

__END__

=head1 LOG FORMATS

=head2 Common Log Format

    my $foo = Regexp::Log::Common->new( format  => ':common' );

The Common Log Format is made up of several fields, each delimited by a single
space.

=over 4

=item * Fields:

  remotehost rfc931 authuser [date] "request" status bytes

=item * Example:

  127.0.0.1 - - [19/Jan/2005:21:47:11 +0000] "GET /brum.css HTTP/1.1" 304 0

  For the above example:
  remotehost: 127.0.0.1
  rfc931: -
  authuser: -
  [date]: [19/Jan/2005:21:47:11 +0000]
  "request": "GET /brum.css HTTP/1.1"
  status: 304
  bytes: 0

=item * Available Capture Fields

  * host
  * rfc
  * authuser
  * date
  ** ts (date without the [])
  * request
  ** req (request without the quotes)
  * status
  * bytes

=back

=head2 Extended Common Log Format

    my $foo = Regexp::Log::Common->new( format  => ':extended' );

The Extended Common Log Format is made up of several fields, each delimited by
a single space.

=over 4

=item * Fields:

  remotehost rfc931 authuser [date] "request" status bytes "referer" "user_agent"

=item * Example:

  127.0.0.1 - - [19/Jan/2005:21:47:11 +0000] "GET /brum.css HTTP/1.1" 304 0 "http://birmingham.pm.org/" "Mozilla/2.0GoldB1 (Win95; I)"

  For the above example:
  remotehost: 127.0.0.1
  rfc931: -
  authuser: -
  [date]: [19/Jan/2005:21:47:11 +0000]
  "request": "GET /brum.css HTTP/1.1"
  status: 304
  bytes: 0
  "referer": "http://birmingham.pm.org/"
  "user_agent": "Mozilla/2.0GoldB1 (Win95; I)"

=item * Available Capture Fields

  * host
  * rfc
  * authuser
  * date
  ** ts (date without the [])
  * request
  ** req (request without the quotes)
  * status
  * bytes
  * referer
  ** ref (referer without the quotes)
  * useragent
  ** ua (useragent without the quotes)

=back

=head1 BUGS, PATCHES & FIXES

There are no known bugs at the time of this release. However, if you spot a
bug or are experiencing difficulties that are not explained within the POD
documentation, please submit a bug to the RT system (see link below). However,
it would help greatly if you are able to pinpoint problems or even supply a
patch.

Fixes are dependent upon their severity and my availability. Should a fix not
be forthcoming, please feel free to (politely) remind me by sending an email
to barbie@cpan.org .

RT: L<http://rt.cpan.org/Public/Dist/Display.html?Name=Regexp-Log-Common>

=head1 SEE ALSO

L<Regexp::Log>

=head1 CREDITS

BooK for initially putting the idea into my head, and the thread on a perl
message board, that wanted the help that was solved with this exact module.

=head1 AUTHOR

  Barbie <barbie@cpan.org>
  for Miss Barbell Productions, L<http://www.missbarbell.co.uk>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2005-2012 Barbie for Miss Barbell Productions.

  This module is free software; you can redistribute it and/or
  modify it under the Artistic License v2.

=cut
