package Smolder::TAPHTMLMatrix;
use strict;
use warnings;

use Test::TAP::Model::Visual;
use Test::TAP::Model::Consolidated;
use Carp qw/croak/;
use File::Spec;
use File::Path;
use URI::file;
use Template;
use Smolder::Conf qw(InstallRoot);
use Smolder::Control;

use overload '""' => "detail_html";

our $TMPL = Template->new(
    COMPILE_DIR  => File::Spec->tmpdir(),
    COMPILE_EXT  => '.ttc',
    INCLUDE_PATH => File::Spec->catdir( InstallRoot, 'templates' ),
    ABSOLUTE     => 1,
);

# use Smolder::Control's version
sub static_url {
    return Smolder::Control->static_url(shift);
}

sub new {
	my ( $pkg, @models ) = @_;

	my $ext = pop @models unless eval { $models[-1]->isa("Test::TAP::Model") };

	@models || croak "must supply a model to graph";

	my $self = bless {}, $pkg;

	$self->model(@models);
	$self->extra($ext);
	
	$self;
}

sub title { 
    my ($self, $title) = @_;
    $self->{title} = $title if( $title );
    return $self->{title} || ("TAP Matrix - " . gmtime() . " GMT");
}

sub tests {
	my $self = shift;
	[ sort { $a->name cmp $b->name } $self->model->test_files ];
}

sub model {
	my $self = shift;
	if (@_) {
		$self->{model} = $_[0]->isa("Test::TAP::Model::Consolidated")
			? shift
			: Test::TAP::Model::Consolidated->new(@_);
	}

	$self->{model};
}

sub extra {
	my $self = shift;
	$self->{extra} = shift if @_;
	$self->{extra};
}

sub tmpl_file {
	my $self = shift;
    my $file = shift;
    $self->{tmpl_file} = $file if $file;
    return $self->{tmpl_file}
}

sub tmpl_obj {
    my $self = shift;
    # use the package level var to hold the object
    # to use TT's in-memory caching
    return $TMPL;
}

sub detail_html {
	my $self = shift;
	$self->process_tmpl($self->tmpl_file || $self->detail_template);
}

sub summary_html {
	my $self = shift;
	$self->process_tmpl($self->tmpl_file || $self->summary_template);
}

sub process_tmpl {
	my $self = shift;
    my $file = shift;
    my $output;
    $self->tmpl_obj->process($file, { page => $self }, \$output)
        or croak "Problem processing template file '$file': "
        , $self->tmpl_obj->error;
    return $output;
}

sub detail_template {
	my $self = shift;
    return File::Spec->catfile('TAP', 'detailed_view.html');
}

sub summary_template {
	my $self = shift;
    return File::Spec->catfile('TAP', 'summary_view.html');
}

__END__

=pod

=head1 NAME

Smolder::TAPHTMLMatrix - Smolder derivative of L<Test::TAP::HTMLMatrix>.

=head1 SYNOPSIS

	use Smolder::TAPHTMLMatrix;
	use Test::TAP::Model::Visual;

	my $model = Test::TAP::Model::Visual->new(...);

	my $v = Smolder::TAPHTMLMatrix->new($model);

	print $v->detail_html;

=head1 DESCRIPTION

This module is a wrapper for a template and some visualization classes, that
knows to take a L<Test::TAP::Model> object, which encapsulates test results,
and produce a pretty html file.

=head1 METHODS

=over 4

=item new (@models, $?extra)

@model is at least one L<Test::TAP::Model> object (or exactly one
L<Test::TAP::Model::Consolidated>) to extract results from, and the optional
$?extra is a string to put in <pre></pre> at the top.

=item detail_html

=item summary_html

Returns an HTML string for the corresponding template.

This is also the method implementing stringification.

=item model

=item extra

=item tmpl_file

=item tmpl_obj

Just settergetters. You can override these for added fun.

=item title

A reasonable title for the page:

	"TAP Matrix - <gmtime>"

=item tests

A sorted array ref, resulting from $self->model->test_files;

=item detail_template

=item summary_template

=item process_tmpl

Processes the L<Template> object returned from L<tmpl_obj> with the given
template and returns it.

=back
