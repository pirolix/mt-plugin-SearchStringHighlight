package MT::Plugin::Search::OMV::SearchStringHighlight;
# $Id$

use strict;
use MT 5;
use MT::Util;

use vars qw( $VENDOR $MYNAME $VERSION );
($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = '0.20'. ($revision ? ".$revision" : '');

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
    id => $MYNAME,
    key => $MYNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    plugin_link => 'http://www.magicvox.net/archive/2010/05152010/', # blog
    doc_link => 'http://lab.magicvox.net/trac/mt-plugins/wiki/SearchStringHighlight', # trac
    description => <<PERLHEREDOC,
<__trans phrase="Highlight the matched string in the entry.">
PERLHEREDOC
    registry => {
        tags => {
            function => {
                SearchStringHighlight => \&tag_searchstringhighlight,
            },
        },
    },
});
MT->add_plugin ($plugin);



### SearchStringHighlight
sub tag_searchstringhighlight {
    my ($ctx, $args) = @_;

    my $needle = $ctx->stash ('search_string')
        or return '';

    my $entry = $ctx->stash ('entry')
        or return $ctx->_no_entry_error ();
    my $text = ($entry->text || ''). ($entry->text_more || '');
    $text = MT::Util::remove_html ($text);

    # Arguments
    my $ql1 = $args->{'length'} || 20;
    my $blog = $ctx->stash('blog');
    my $words = $args->{words} || ($blog ? $blog->words_in_excerpt : 40);
    my $tag = $args->{tag} || 'b';
    $args->{cite} ||= 5;

    # Matching
    my @matches;
    while ($text =~ s/((.{0,$ql1}$needle)+.{0,$ql1})//i) {
        push @matches, $1;
    }
    #
    pop @matches while $args->{cite} < @matches;

    $text = @matches
        ? join '...', '', @matches, ''
        : $entry->get_excerpt;

    # Highlight with tag
    $text =~ s!($needle)!<$tag>$1</$tag>!gsi;

    $text;
}

1;