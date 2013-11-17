package QBit::WebInterface::Controller::Multistate;

use qbit;

use base qw(QBit::WebInterface::Controller);

__PACKAGE__->register_rights(
    [
        {
            name        => 'multistate_controller',
            description => d_gettext('Project multistates actions'),
            rights      => {multistate_graph_view => d_gettext('Right to view multistate graph'),},
        }
    ]
);

sub graph : CMD : DEFAULT {
    my ($self) = @_;

    return $self->denied() unless $self->check_rights('multistate_graph_view');

    my $models = $self->app->get_models();

    my @accessors;
    while (my ($accessor, $package) = each(%$models)) {
        push(@accessors, $accessor) if $package->isa('QBit::Application::Model::Multistate');
    }

    my $graph_svg = '';
    my $accessor  = $self->request->param('accessor');
    if (   defined($accessor)
        && $self->app->can($accessor)
        && $self->app->$accessor->isa('QBit::Application::Model::Multistate'))
    {
        $graph_svg =
          $self->app->$accessor->get_multistates_graph(private_names => $self->request->param('private_names'))
          ->as_svg();
        $graph_svg =~ s/^.+?<svg/<svg style="max-width: 100%;" onclick="this.style.maxWidth=''"/s;
    }

    return $self->from_template('multistate/graph.tt2', vars => {accessors => \@accessors, graph_svg => $graph_svg});
}

TRUE;
