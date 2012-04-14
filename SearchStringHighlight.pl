package MT::Plugin::OMV::SearchStringHighlight;

use strict;
use MT 4;
use MT::Util;

use vars qw( $MYNAME $VERSION );
$MYNAME = 'SearchStringHighlight';
$VERSION = '0.20';

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new({
    id => $MYNAME,
    key => $MYNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    doc_link => 'http://www.magicvox.net/archive/2010/05152010/',
    description => <<PERLHEREDOC,
<__trans phrase="Highlight the matched string in the entry.">
PERLHEREDOC
#    l10n_class => $MYNAME. '::L10N',
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

    # Matching
    my $ql1 = $args->{'length'} || 20;
    my @matches;
    while ($text =~ s/((.{0,$ql1}$needle)+.{0,$ql1})//i) {
        push @matches, $1;
    }

    # Limit the number of citing
    $args->{cite} ||= 5;
    pop @matches while $args->{cite} < @matches;

    # Make a string
    $text = @matches
        ? join '...', '', @matches, ''
        : $entry->get_excerpt;

    # Highlight with tag
    my $tag = $args->{tag} || 'b';
    $text =~ s!($needle)!<$tag>$1</$tag>!gsi;

    $text;
}

1;