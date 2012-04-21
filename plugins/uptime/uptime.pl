package MT::Plugin::Admin::OMV::Admin::uptime;

use strict;

use vars qw( $VENDOR $MYNAME $VERSION );
($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = "0.02_$revision";

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
        name => $MYNAME,
        id => lc $MYNAME,
        key => lc $MYNAME,
        version => $VERSION,
        author_name => 'Open MagicVox.net',
        author_link => 'http://www.magicvox.net/',
        plugin_link => 'http://www.magicvox.net/archive/2010/01300449/', # blog
        doc_link => 'http://lab.magicvox.net/trac/mt-plugins/wiki/uptime', # trac
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
        callbacks => {
            'MT::App::CMS::template_source.header' => sub {
                5.0 <= $MT::VERSION
                    ? return _source_header_v5 (@_) : 0;
                4.0 <= $MT::VERSION
                    ? return _source_header_v4 (@_) : 0;
            },
            'MT::App::CMS::template_param' => \&hdlr_parameter,
        },
    });
}



###
sub hdlr_parameter {
    my ($app, $tmpl, $param) = @_;

    my $out = lc `uptime`;
    ($param->{la_1}, $param->{la_5}, $param->{la_15}) =
        $out =~ /([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)/;
}

###
sub _source_header_v5 {
    my ($cb, $app, $tmpl) = @_;

    my $old = quotemeta (<<'MTMLHEREDOC');
<ul id="utility-nav-list">
MTMLHEREDOC

    my $new = <<'MTMLHEREDOC';
<li style="padding-right:0.5em;">
<img src="<mt:var static_uri>plugins/uptime/chart_bar.png" alt="Load Average" />
<span<mt:if name="la_1" gt="1.00"> style="color:red; font-weight:bold;"</mt:if> title="1<__trans phrase="minutes">"><$mt:var name="la_1"$></span>,
<span<mt:if name="la_5" gt="1.00"> style="color:red; font-weight:bold;"</mt:if> title="5<__trans phrase="minutes">"><$mt:var name="la_5"$></span>,
<span<mt:if name="la_15" gt="1.00"> style="color:red; font-weight:bold;"</mt:if> title="15<__trans phrase="minutes">"><$mt:var name="la_15"$></span></li>
MTMLHEREDOC
    $$tmpl =~ s/($old)/$1$new/;
}

sub _source_header_v4 { _source_header_v5 (@_); }

1;