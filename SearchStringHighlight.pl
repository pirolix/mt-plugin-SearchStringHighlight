package MT::Plugin::OMV::SearchStringHighlight;

use strict;
use MT 4;
use MT::Util;
use MT::I18N;

use vars qw( $MYNAME $VERSION );
$MYNAME = 'SearchStringHighlight';
$VERSION = '0.11';

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



my $utf8 = join '|', qw{
    [\x00-\x7f]
    [\xc0-\xdf][\x80-\xbf]
    [\xe0-\xef][\x80-\xbf][\x80-\xbf]
    [\xf0-\xf7][\x80-\xbf][\x80-\xbf][\x80-\xbf]
    [\xf8-\xfb][\x80-\xbf][\x80-\xbf][\x80-\xbf][\x80-\xbf]
    [\xfc-\xfd][\x80-\xbf][\x80-\xbf][\x80-\xbf][\x80-\xbf][\x80-\xbf]
};

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
    my $ql2 = $ql1 * 2;
    my $blog = $ctx->stash('blog');
    my $words = $args->{words} || $blog ? $blog->words_in_excerpt : 40;
    my $tag = $args->{tag} || 'b';

    # convert into UTF8
    my $charset = lc MT->config->PublishCharset;
    $text = MT::I18N::encode_text ($text, $charset, 'utf8') if $charset ne 'utf8';

    # Matching
    my @matches = ('');
    while (my ($_find) = $text =~ /(?:$utf8){0,$ql1}($needle)(?:(?:$utf8){0,$ql2}(?:$needle))*(?:$utf8){0,$ql1}/s) {
        push @matches, $&;
        $_find = quotemeta $&;
        $text =~ s/[\s\S]*?$_find//s;
    }
    $text = 1 < @matches
        ? join '...', @matches, ''
        : $entry->get_excerpt;

    # first n characters
    ($text) = $text =~ /((?:$utf8){0,$words})/;

    # Highlight
    $text =~ s!($needle)!<$tag>$1</$tag>!gs;

    # Revert from UTF8
    $text = MT::I18N::encode_text ($text, 'utf8', $charset) if $charset ne 'utf8';
    $text;
}

1;