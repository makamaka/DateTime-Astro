package DateTime::Event::SolarTerm;
use strict;
use DateTime::Set;
use DateTime::Astro qw(dt_from_moment moment new_moon_after solar_longitude);
use Exporter 'import';
use POSIX ();

our @EXPORT_OK = qw(
    major_term_after
    major_term_before
    major_term
    minor_term_after
    minor_term_before
    minor_term
    no_major_term_on
    prev_term_at
    CHUNFEN
    SHUNBUN
    QINGMING
    SEIMEI
    GUYU
    KOKUU
    LIXIA
    RIKKA
    XIAOMAN
    SHOMAN
    MANGZHONG
    BOHSHU
    XIAZHO
    GESHI
    SUMMER_SOLSTICE
    XIAOSHU
    SHOUSHO
    DASHU
    TAISHO
    LIQIU
    RISSHU
    CHUSHU
    SHOSHO
    BAILU
    HAKURO
    QIUFEN
    SHUUBUN
    HANLU
    KANRO
    SHUANGJIANG
    SOHKOH
    LIDONG
    RITTOH
    XIAOXUE
    SHOHSETSU
    DAXUE
    TAISETSU
    DONGZHI
    TOHJI
    WINTER_SOLSTICE
    XIAOHAN
    SHOHKAN
    DAHAN
    DAIKAN
    LICHUN
    RISSHUN
    YUSHUI
    USUI
    JINGZE
    KEICHITSU
);

sub prev_term_at {
    return dt_from_moment(prev_term_at_from_moment(moment($_[0]), $_[1]));
}

sub major_term_after {
    return $_[0] if $_[0]->is_infinite;
    return dt_from_moment( major_term_after_from_moment( moment($_[0]) ) );
}

sub major_term_before {
    return $_[0] if $_[0]->is_infinite;
    return dt_from_moment( major_term_before_from_moment( moment($_[0]) ) );
}

sub major_term {
    return DateTime::Set->from_recurrence(
        next => sub {
            return $_[0] if $_[0]->is_infinite;
            return major_term_after($_[0]);
        },
        previous => sub {
            return $_[0] if $_[0]->is_infinite;
            return major_term_before($_[0]);
        },
    );
}

sub minor_term_after {
    return $_[0] if $_[0]->is_infinite;
    return dt_from_moment( minor_term_after_from_moment( moment($_[0]) ) );
}

sub minor_term_before {
    return $_[0] if $_[0]->is_infinite;
    return dt_from_moment( minor_term_before_from_moment( moment($_[0]) ) );
}

sub minor_term {
    return DateTime::Set->from_recurrence(
        next => sub {
            return $_[0] if $_[0]->is_infinite;
            return minor_term_after($_[0]);
        },
        previous => sub {
            return $_[0] if $_[0]->is_infinite;
            return minor_term_before($_[0]);
        },
    );
}

# [1] p.245 (current_major_term)
sub last_major_term_index {
    return () if $_[0]->is_infinite;
    my $l = solar_longitude($_[0]);
    my $x = 2 + POSIX::floor($l / 30);
    return $x % 12 || 12;
}

# [1] p.245 (current_minor_term)
sub last_minor_term_index {
    return () if $_[0]->is_infinite;
    my $l = solar_longitude($_[0]);
    my $x = 3 + POSIX::floor($l - 15) / 30;
    return $x % 12 || 12;
}

# [1] p.250
sub no_major_term_on {
    my $next_new_moon = new_moon_after( $_[0] );
    return last_major_term_index( $_[0] ) == last_major_term_index( $next_new_moon );
}

1;
