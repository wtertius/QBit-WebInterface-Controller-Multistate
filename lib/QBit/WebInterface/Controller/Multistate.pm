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

    my @accessors =
      grep {$self->app->$_->isa('QBit::Application::Model::Multistate')} keys(%{$self->app->get_models()});

    return $self->from_template('multistate/graph.tt2', vars => {accessors => \@accessors});
}

sub graph_image : CMD {
    my ($self) = @_;

    return $self->denied() unless $self->check_rights('multistate_graph_view');

    my %accessors = map {$_ => 1}
      grep {$self->app->$_->isa('QBit::Application::Model::Multistate')} keys(%{$self->app->get_models()});

    my $accessor = $self->request->param('accessor', '');
    return $self->response->status(404) unless $accessors{$accessor};

    $self->response->content_type('image/png');
    return $self->response->data(\$self->app->$accessor->get_multistates_graph()->as_png());
}

TRUE;
