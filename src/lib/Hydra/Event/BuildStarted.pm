package Hydra::Event::BuildStarted;

use strict;
use warnings;

sub parse :prototype(@) {
    unless (@_ == 1) {
        die "build_started: payload takes only one argument, but ", scalar(@_), " were given";
    }

    my ($build_id) = @_;

    unless ($build_id =~ /^\d+$/) {
        die "build_started: payload argument should be an integer, but '", $build_id, "' was given"
    }

    return Hydra::Event::BuildStarted->new(int($build_id));
}

sub new {
    my ($self, $id) = @_;
    return bless {
        "build_id" => $id,
        "build" => undef
    }, $self;
}

sub load {
    my ($self, $db) = @_;

    if (!defined($self->{"build"})) {
        $self->{"build"} = $db->resultset('Builds')->find($self->{"build_id"})
            or die "build $self->{'build_id'} does not exist\n";
    }
}

sub execute {
    my ($self, $db, $plugin) = @_;

    $self->load($db);

    $plugin->buildStarted($self->{"build"});

    return 1;
}

1;
