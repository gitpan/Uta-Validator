package Uta::Validator;

use utf8;
use strict;
use CGI::Carp qw/croak carp/;

my $mail_regex = 
  q{(?:[^(\040)<>@,;:".\\\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\\} .
  q{\[\]\000-\037\x80-\xff])|"[^\\\\\x80-\xff\n\015"]*(?:\\\\[^\x80-\xff][} .
  q{^\\\\\x80-\xff\n\015"]*)*")(?:\.(?:[^(\040)<>@,;:".\\\\\[\]\000-\037\x} .
  q{80-\xff]+(?![^(\040)<>@,;:".\\\\\[\]\000-\037\x80-\xff])|"[^\\\\\x80-} .
  q{\xff\n\015"]*(?:\\\\[^\x80-\xff][^\\\\\x80-\xff\n\015"]*)*"))*@(?:[^(} .
  q{\040)<>@,;:".\\\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\\\[\]\0} .
  q{00-\037\x80-\xff])|\[(?:[^\\\\\x80-\xff\n\015\[\]]|\\\\[^\x80-\xff])*} .
  q{\])(?:\.(?:[^(\040)<>@,;:".\\\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,} .
  q{;:".\\\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\\\x80-\xff\n\015\[\]]|\\\\[} .
  q{^\x80-\xff])*\]))*};

#------------------------------------------------------------------------
# validation values
# * 
#------------------------------------------------------------------------
sub validation {
  my($self, %args) = @_;
  my @err = ();
  while (my($key, $message) = each(%args)) {
    foreach my $param(@{$$message[1]}) {
      # arrays ...
      if (ref $param eq 'ARRAY') {
        # length check
        if ($param->[0] eq 'LENGTH') {
          if (length $self->req->{$key} < $param->[1] || length $self->req->{$key} > $param->[2]) {
            push(@err, "$$message[0]��$param->[1]�����ȏ�$param->[2]�����ȉ��œ��͂��Ă�������");
          }
        }
        # between num
        if ($param->[0] eq 'BETWEEN') {
          if ($self->req->{$key} < $param->[1] || $self->req->{$key} > $param->[2]) {
            push(@err, "$$message[0]��$param->[1]�ȏ�$param->[2]�ȉ��̐��l�œ��͂��Ă�������");
          }
        }
      }
      else {
        # blank check
        if ($param eq 'NOT_BLANK') {
          unless (defined $self->req->{$key} && length $self->req->{$key} > 0) {
            push(@err, "$$message[0]������(�܂��͑I��)����Ă��܂���");
          }
        }
        # numeric?
        if ($param eq 'INT') {
          if ($self->req->{$key} =~ /[^\d]/) {
            push(@err, "$$message[0]�������ł͂���܂���");
          }
        }
        # w value?
        if ($param eq 'ENG') {
          if ($self->req->{$key} =~ /[^\w]/) {
            push(@err, "$$message[0]�����p�p�����ł͂���܂���");
          }
        }
        # mail address?
        if ($param eq 'MAIL') {
          if ($self->req->{$key} !~ /^$mail_regex$/o) {
            push(@err, "$$message[0]���s���ȃ��[���A�h���X�ł�");
          }
        }
      }
    }
  }
  return $#err >= 0 ? ['ng', \@err] : ['ok'];
}

#------------------------------------------------------------------------
# does the value exist?
# * 
#------------------------------------------------------------------------
sub is_empty {
  my($self, %args) = @_;
  while (my($key, $message) = each(%args)) {
    unless (defined $self->req->{$key} && length $self->req->{$key} > 0) {
      $self->error($message);
    }
  }
}

#------------------------------------------------------------------------
# is the value a numerical valuw?
# * 
#------------------------------------------------------------------------
sub is_numeric {
  my($self, @args) = @_;
  map {
    if ($self->req->{$_} =~ /[^0-9]/) {
      $self->error($_.' is not numerical value');
    }
  } @args;
}

1;
