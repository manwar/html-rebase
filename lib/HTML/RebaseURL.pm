package HTML::RebaseURL;
use strict;
use URI::WithBase;
use URI::URL;
use Exporter 'import';
use vars qw(@EXPORT_OK $VERSION);
$VERSION = '0.01';
@EXPORT_OK= qw(rebase_html rebase_css rebase_html_inplace rebase_css_inplace);

=head1 NAME

HTML::RebaseURL - rewrite HTML links to be relative to a given URL

=head1 SYNOPSIS

  use HTML::RebaseURL qw(rebase_html rebase_css);
  my $html = <<HTML;
  <html>
  <head>
  <link rel="stylesheet" src="http://localhost:5000/css/site.css" />
  </head>
  <body>
  <a href="http://perlmonks.org">Go to Perlmonks.org</a>
  <a href="http://localhost:5000/index.html">Go to home page/a>
  </body>
  </html>
  HTML

  my $local_html = rebase_html( "http://localhost:5000/about.html", $html );
  print $local_html;
  __END__
  <html>
  <head>
  <link rel="stylesheet" src="../css/site.css" />
  </head>
  <body>
  <a href="http://perlmonks.org">Go to Perlmonks.org</a>
  <a href="../index.html">Go to home page/a>
  </body>
  </html>

=head2 C<< rebase_html >>

Rewrites all HTML links to be relative to the given URL. This
only rewrites things that look like C<< src= >> and C<< href= >> attributes.
Unquoted attributes will not be rewritten. This should be fixed.

=cut

sub rebase_html {
    my($url, $html)= @_;
    
    #croak "Can only rewrite relative to an absolute URL!"
    #    unless $url->is_absolute;

    # Rewrite absolute to relative
    rebase_html_inplace( $url, $html );
    
    $html
}

sub rebase_html_inplace {
    my $url = shift;
    $url = URI::URL->new( $url );
    
    #croak "Can only rewrite relative to an absolute URL!"
    #    unless $url->is_absolute;

    # Rewrite absolute to relative
    # Rewrite all tags with quotes
    $_[0] =~ s!((?:\bsrc|\bhref)\s*=\s*(["']))(.+?)\2!$1 . relative_url($url,"$3") . $2!ge;
    # Rewrite all tags without quotes
    $_[0] =~ s!((?:\bsrc|\bhref)\s*=\s*)([^>"' ]+)!$1 . '"' . relative_url($url,"$2") . '"'!ge;
}

=head2 C<< rebase_css >>

Rewrites all CSS links to be relative to the given URL. This
only rewrites things that look like C<< url( ... ) >> .

=cut

sub rebase_css {
    my($url, $css)= @_;
    
    #croak "Can only rewrite relative to an absolute URL!"
    #    unless $url->is_absolute;

    # Rewrite absolute to relative
    rebase_css_inplace( $url, $css );
    
    $css
}

sub rebase_css_inplace {
    my $url = shift;
    $url = URI::URL->new( $url );
    
    #croak "Can only rewrite relative to an absolute URL!"
    #    unless $url->is_absolute;

    # Rewrite absolute to relative
    $_[0] =~ s!(url\(\s*(["']?))([^)]+?)\2!$1 . relative_url($url,"$3") . $2!ge;
}

sub relative_url {
    my( $curr, $url ) = @_;
    my $res = URI::WithBase->new( $url, $curr );
    # Copy parts that URI::WithBase doesn't...
    for my $part (qw( scheme host port )) {
        if( ! defined $res->$part and defined $curr->$part ) {
            $res->$part( $curr->$part );
        };
    };
    $res = $res->rel();
    
    $res
};

=head1 CAVEATS

=head2 Does not handle C<< <base> >> tags

If the HTML contains a C<< <base> >> tag, it's C<< href= >> attribute
is not inspected but simply rewritten. Ideally, the C<< href= >> attribute
should be identical to the URL passed to C<< rebase_html >>.

=head2 Uses regular expressions to do all parsing

Instead of parsing the HTML into a DOM, performing the modifications and
then writing the DOM back out, this module uses a simplicistic regular
expressions to recognize C<< href= >> and C<< src= >> attributes and
to rewrite them.

=head1 REPOSITORY

The public repository of this module is 
L<http://github.com/Corion/html-rebaseurl>.

=head1 SUPPORT

The public support forum of this module is
L<http://perlmonks.org/>.

=head1 BUG TRACKER

Please report bugs in this module via the RT CPAN bug queue at
L<https://rt.cpan.org/Public/Dist/Display.html?Name=HTML-RebaseURL>
or via mail to L<html-rebaseurl-Bugs@rt.cpan.org>.

=head1 AUTHOR

Max Maischein C<corion@cpan.org>

=head1 COPYRIGHT (c)

Copyright 2015 by Max Maischein C<corion@cpan.org>.

=head1 LICENSE

This module is released under the same terms as Perl itself.

=cut

1;