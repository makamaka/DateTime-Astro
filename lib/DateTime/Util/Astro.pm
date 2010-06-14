package DateTime::Util::Astro;
use strict;
use XSLoader;
use Exporter 'import';
use DateTime;

BEGIN {
    our @EXPORT_OK = qw(
        dt_from_moment
        ephemeris_correction
        gregorian_year_from_rd
        gregorian_components_from_rd
        julian_centuries
        julian_centuries_from_moment
        lunar_longitude
        lunar_longitude_from_moment
        lunar_phase
        moment
        nth_new_moon
        polynomial
        solar_longitude
        solar_longitude_from_moment
    );
    our $VERSION = '0.19999';

    my $backend = $ENV{PERL_DATETIME_UTIL_ASTRO_BACKEND} || 'XS';
    my $loaded;
    my @errors;
    if ($backend ne 'PP') {
        eval {
            XSLoader::load __PACKAGE__, $VERSION;
            require DateTime::Util::AstroXS;
            $loaded = 'XS';
        };
        if (my $e = $@) {
            push @errors, "Failed to load XS backend: $e";
        }
    }

    if (! $loaded) {
        eval {
            require DateTime::Util::AstroPP;
            $loaded = 'PP';
        };
        if (my $e = $@) {
            push @errors, "Failed to load PP backend: $e";
            die("DateTime::Util::Astro: Failed to load both XS and PP implementations. Can't proceed\n" . join("\n", @errors));
        }
    }
    eval "sub BACKEND() { '$loaded' }";
}

sub moment {
    my $dt = shift;
    my ($rd, $seconds) = $dt->utc_rd_values;
    return $rd + ($seconds / 86400);
}

sub dynamical_moment_from_dt {
    return dynamical_moment( moment( $_[0] ) );
}

sub julian_centuries {
    return julian_centuries_from_moment( dynamical_moment_from_dt( $_[0] ) );
}

sub lunar_phase {
    return lunar_phase_from_moment( moment($_[0]) );
}

sub solar_longitude {
    return solar_longitude_from_moment( moment($_[0]) );
}
    
sub lunar_longitude {
    return lunar_longitude_from_moment( moment($_[0]) );
}

1;

__END__

=head1 NAME

DateTime::Util::Astro - Functions For Astromical Calendars

=head1 DESCRIPTION

DateTime::Util::Astro implements functions used in astronomical calendars.

This module is best used in environments where a C compiler and the MPFR arbitrary precision math library is installed. It can fallback to using Math::BigInt, but that would pretty much render it useless because of its speed.

=head1 FUNCTIONS

=head2 BACKEND()

Returns 'XS' or 'PP', noting the current backend.

=head2 dt_from_moment($moment)

Given a moment (days since rd + fractional seconds), returns a DateTime object in UTC

=head2 dynamica_moment($moment)

Computes the moment value from given moemnt, taking into account the ephemeris correction.

=head2 dynamical_moment_from_dt($dt)

Computes the moment value from a DateTime object, taking into account the ephemeris correction.

=head2 ephemeris_correction($moment)

Computes the ephemeris correction on a given moment

=head2 gregorian_components_from_rd($rd_days)

Computes year, month, date from RD value

=head2 gregorian_year_from_rd($rd_days)

Computes year from RD value

=head2 julian_centuries($dt)

Computes the julian centuries for given DateTime object

=head2 julian_centuries_from_moment($moment)

Computes the julian centuries for given moment

=head2 lunar_phase($dt)

Computes the lunar phase for given DateTime object

=head2 lunar_phase_from_moment($moment)

Computes the lunar phase for given moment

=head2 polynomial($x, ...)

Computes the polynomical expression using $x as the variable. The left most argument is the constant, and each successive argument is the coefficient for the next power of $x

=head2 ymd_seconds_from_moment($moment)

Computes the gregorian components (year, month, day) from the RD date, and the number of seconds from the fractional part.

=head2 lunar_longitude($dt)

Returns the Moon's longitude on the given date $dt

=head2 lunar_longitude_from_moment($moment)

Returns the Moon's longitude on the given moment $moment

=head2 moment($dt)

Returns the date $dt expressed in moment

=head2 nth_new_moon($n)

Returns the $n-th new moon, in $moment.

Currently the new moons dates are accurate to about within +/- 60 seconds of the actual new moon for modern dates. 

For older dates, the accuraccy degrades a bit to about +/- 5 minutes.

=head2 solar_longitude($dt)

Returns the Sun's longitude on the given date $dt

=head2 solar_longitude_from_moment($moment)

Returns the Sun's longitude on the given moment $moment

=cut