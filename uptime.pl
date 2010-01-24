package MT::Plugin::OMB::uptime;

use strict;

use vars qw( $MYNAME $VERSION );
$MYNAME = 'uptime';
$VERSION = '0.01';

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new({
        name => $MYNAME,
        id => lc $MYNAME,
        key => lc $MYNAME,
        version => $VERSION,
        author_name => 'Open MagicVox.net',
        author_link => 'http://www.magicvox.net/',
        description => <<HTMLHEREDOC,
a Widget that shows your server&apos;s load averages.
HTMLHEREDOC
});
MT->add_plugin( $plugin );

sub instance { $plugin; }

### Registry
sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        applications => {
            cms => {
                widgets => {
                    $MYNAME => {
                        label    => 'Load Averages',
                        template => 'tmpl/uptime.tmpl',
                        handler  => \&hdlr_parameter,
                        set      => 'sidebar',
                        singular => 1,
                    },
                },
            },
        },
    });
}



###
sub hdlr_parameter {
    my ($app, $tmpl, $param) = @_;

    my $out = lc `uptime`;
    ($param->{la_1}, $param->{la_5}, $param->{la_15}) =
        $out =~ /load\s+averages\:\s*([\d+.]+)\s*,\s*([\d+.]+)\s*,\s*([\d+.]+)/;
}

1;