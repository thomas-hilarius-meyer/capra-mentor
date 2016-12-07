#!/usr/bin/perl

# capra:testimonium - Zeugnisprogramm
# capra:mentor - elektronisches Notenbüchlein mit Funktionen
# capra:censura - Bewertung einer Klassenarbeit o.ä.

# pflegt datenaustausch mit mentor testimonium und censura. 


use strict;
use utf8;
use open ':encoding(utf8)';
use Data::Dumper;
$Data::Dumper::Purity=1;

#use YAML qw 'DumpFile LoadFile';

use Tk;
use Tk::DialogBox;
use Tk::Pane;			# nötig seit Einbau der scrollbars


# Datenstruktur: 

my $mentor_programmversion_prog = "capra:mentor-0.1";


my $filename;
my $import_filename;

my $mentor_klasse;
my $mentor_stufe = "5";

my $mentor_schuelerzahl;
my $mentor_s; #schuelernummer
my $mentor_hj = "1"; # halbjahr: 1 oder 2
my $mentor_welches_fach = "Deutsch";

my @mentor_nachname;
my @mentor_vorname;
my @mentor_tel;
my @mentor_email;
my @mentor_geburtsdatum;
my @mentor_anrede;
my @mentor_konfession;
my @mentor_adresse;

# fünfdimensionale Felder: blubb(schueler)(fach)(stufe)(halbjahr)(nr)
my @mentor_klassenarbeiten;
my @mentor_tests;
my @mentor_hausaufgaben;
my @mentor_ha_da;       # jeweils frisch berechnen, nur für (schueler)
my @mentor_ha_fehlt;    # ....
my @mentor_mitarbeit;
my @mentor_heft;
my @mentor_abfrage; 

# dreidimensional: blubb (schueler)(fach)(stufe)
my @mentor_mitarbeit_errechnet;
my @mentor_mitarbeit_gegeben;

my @mentor_verhalten_gegeben;  # mentor_verhalten_errechnet ist sinnlos...

my @mentor_hjz_errechnet;
my @mentor_hjz_gegeben;
my @mentor_jz_errechnet;
my @mentor_jz_gegeben;

# schuelerunabhängig:
my %benachrichtigungstexte = {};

my $prozentsatz_abfrage;
my $prozentsatz_hausaufgaben;
my $prozentsatz_heftnote;
my $prozentsatz_klassenarbeiten;
my $prozentsatz_tests;


my $main = MainWindow  -> new( -title => "$mentor_programmversion_prog", -height => "220");

$main -> Menubutton ( -text => "Datei",
				       -justify => 'left', 
				       -relief => 'groove',
				       -tearoff => 0,
				       -menuitems => [['command' => "Klasse laden", -command => \&laden],
						      ['command' => "Klasse speichern", -command => \&speichern],
						      "-",
						      ['command' => "Klasse (Namen) aus testimonium-Datei (.txz) importieren", -command => \&aaa],
						      ['command' => "Klasse (Namen) aus censura-Datei (.txc) importieren", -command => \&aaa],
						      "-",
						      ['command' => "Beenden", -command => \&beenden]]) -> grid(

$main -> Menubutton ( -text => "Klassenstufe / Halbjahr",
                                       -justify => 'left', 
                                       -relief => 'groove',
                                       -tearoff => 0,
                                       -menuitems => [['radiobutton' => "5", -variable => \$mentor_stufe, -value => "5"],
                                                      ['radiobutton' => "6", -variable => \$mentor_stufe, -value => "6"],
                                                      ['radiobutton' => "7", -variable => \$mentor_stufe, -value => "7"],
                                                      ['radiobutton' => "8", -variable => \$mentor_stufe, -value => "8"],
                                                      ['radiobutton' => "9", -variable => \$mentor_stufe, -value => "9"],
                                                      ['radiobutton' => "10", -variable => \$mentor_stufe, -value => "10"],
                                                      "-",
                                                      ['radiobutton' => "1. Halbjahr", -variable => \$mentor_hj, -value => "1"],
                                                      ['radiobutton' => "2. Halbjahr", -variable => \$mentor_hj, -value => "2"],
                                                      ]),
						      
						      
$main -> Menubutton( -text => "Fach",
                                       -justify => 'left', 
                                       -relief => 'groove',
                                       -tearoff => 0,
                                       -menuitems => [['radiobutton' => "Ethik/Religion", -variable => \$mentor_welches_fach, -value => "Ethik/Religion"],
                                                      ['radiobutton' => "Deutsch", -variable => \$mentor_welches_fach, -value => "Deutsch"],
                                                      ['radiobutton' => "Mathematik", -variable => \$mentor_welches_fach, -value => "Mathematik"],
                                                      ['radiobutton' => "Gesellschaftswissenschaften", -variable => \$mentor_welches_fach, -value => "Gesellschaftswissenschaften"],
                                                      ['radiobutton' => "Erdkunde", -variable => \$mentor_welches_fach, -value => "Erdkunde"],
                                                      ['radiobutton' => "Geschichte", -variable => \$mentor_welches_fach, -value => "Geschichte"],
                                                      ['radiobutton' => "Politik", -variable => \$mentor_welches_fach, -value => "Politik"],
                                                      ['radiobutton' => "Naturwissenschaften", -variable => \$mentor_welches_fach, -value => "Naturwissenschaften"],
                                                      ['radiobutton' => "Biologie", -variable => \$mentor_welches_fach, -value => "Biologie"],
                                                      ['radiobutton' => "Physik", -variable => \$mentor_welches_fach, -value => "Physik"],
                                                      ['radiobutton' => "Chemie", -variable => \$mentor_welches_fach, -value => "Chemie"],
                                                      ['radiobutton' => "1. Fremdsprache", -variable => \$mentor_welches_fach, -value => "1. Fremdsprache"],
                                                      ['radiobutton' => "Musik", -variable => \$mentor_welches_fach, -value => "Musik"],
                                                      ['radiobutton' => "Bildende Kunst", -variable => \$mentor_welches_fach, -value => "Bildende Kunst"],
                                                      ['radiobutton' => "Sport", -variable => \$mentor_welches_fach, -value => "Sport"],
                                                      ['radiobutton' => "Arbeitslehre", -variable => \$mentor_welches_fach, -value => "Arbeitslehre"],
                                                      ['radiobutton' => "WPB1", -variable => \$mentor_welches_fach, -value => "WPB1"],
                                                      ['radiobutton' => "WPB2", -variable => \$mentor_welches_fach, -value => "WPB2"],
                                                      ['radiobutton' => "Sprachkurs", -variable => \$mentor_welches_fach, -value => "Sprachkurs"],
                                                     ]
                                                     ),
                        
$main -> Menubutton ( -text => "Info",
				       -justify => 'left', 
				       -relief => 'groove',
				       -tearoff => 0,
				       -menuitems => [['command' => "Gebrauchsanweisung zeigen", -command => \&aaa], 
						      ['command' => "Über $mentor_programmversion_prog", -command => \&programminfo]]),
);

my $frame1;
my $frame2;

  $frame1 = $main -> Frame ( -relief => "raised", -borderwidth => 2) -> grid("-", "-", "-", "-", "-");

  $frame1 -> Label ( -text => "Dateiname:", -width => "12", -anchor => "w") -> grid(
  $frame1 -> Label ( -textvariable => \$filename, -width => "19", -anchor => "w")
  );

  $frame1 -> Label ( -text => "Klasse:", -width => "12", -anchor => "w") -> grid(
  $frame1 -> Label ( -textvariable => \$mentor_klasse, -width => "19", -anchor => "w")
  );
  
  $frame1 -> Label ( -text => "Klassenstufe:", -width => "12", -anchor => "w") -> grid(
  $frame1 -> Label ( -textvariable => \$mentor_stufe, -width => "19", -anchor => "w")
  );

  $frame1 -> Label ( -text => "Halbjahr:", -width => "12", -anchor => "w") -> grid(
  $frame1 -> Label ( -textvariable => \$mentor_hj, -width => "19", -anchor => "w")
  );

  
  $frame1 -> Label ( -text => "Fach:", -width => "12", -anchor => "w") -> grid(
  $frame1 -> Label ( -textvariable => \$mentor_welches_fach, -width => "19", -anchor => "w")
  );
  
  my $schuelerzahl = @mentor_nachname;
  $frame1 -> Label ( -text => "Schülerzahl:", -width => "12", -anchor => "w") -> grid(
  $frame1 -> Label ( -textvariable => \$mentor_schuelerzahl, -width => "19", -anchor => "w")
  );

  
  $frame2 = $main -> Frame ( -relief => "raised", -borderwidth => 2) -> grid("-", "-", "-", "-", "-");

  $frame2 -> Label ( -text => "Programmfunktionen:") -> grid();
  
  $frame2 -> Button ( -text => "Persönliche Daten", -command => \&persoenliche_daten) -> grid(); 
  $frame2 -> Button ( -text => "Notenübersicht", -command => \&notenuebersicht) -> grid();
  $frame2 -> Button ( -text => "Hausaufgaben", -command => \&hausaufgaben)                 -> grid();                                  
  $frame2 -> Button ( -text => "Zeugnisnoten festlegen", -command => \&zeugnisnoten) -> grid();
                                                     
 
MainLoop;


sub censura_import {
  $filename = $main -> getOpenFile ( -title => "Zensur laden", -filetypes => [ ["capra:censura-Dateien", [".txc"] ], 
										  ["alle Dateien",	["*"] 	 ] ] );

  my $schuelerzahl;
  my @zensur;
  my $kategorienzahl;
  my @textbausteinzahl;
  my @textbausteine;
  my @maximalpunkte;
  my @bewertungsclick;
  my @bewertungspunkte;
  if ($filename) {
    open CONFIG, "$filename" or die "*** Datei nicht gefunden! \n";
      undef $/;
      eval <CONFIG> or print "*** Kann Datei nicht auswerten! \n $@";
    close CONFIG;
  };
  &infofenster;
};


sub persoenliche_daten {
  my $namen = $main->DialogBox(
      -title   => "Schuelernamen eintragen",
      -buttons => [ "OK", "Neuer Schüler", "Sortieren", "Hilfe" ]
  );

    my $namenscroll =
        $namen->Scrolled( "Frame", -scrollbars => "oe", -height => "500" )->pack( -fill => "both", -expand => "1" );

    $namenscroll->Label( -text => "Nr." )->grid(
        $namenscroll->Label( -text => "Nachname" ),
        $namenscroll->Label( -text => "Vorname" ),
        $namenscroll->Label( -text => "Geburtsdatum" ),
        $namenscroll->Label( -text => "Konfession" ),
        $namenscroll->Label( -text => "Telefonnummer" ),
        $namenscroll->Label( -text => "email" ),
        $namenscroll->Label( -text => "Adresse" ),
   );

    for ( my $i = 1; $i <= $mentor_schuelerzahl; $i++ ) {
        $namenscroll->Label( -text => "$i :" )->grid(
            $namenscroll->Entry(
                -textvariable => \$mentor_nachname[$i],
                -width        => 30
            ),
            $namenscroll->Entry(
                -textvariable => \$mentor_vorname[$i],
                -width        => 30
            ),

            $namenscroll->Entry(
                -textvariable => \$mentor_geburtsdatum[$i],
                -width        => 12
                ),
            $namenscroll->Entry(
                -textvariable => \$mentor_konfession[$i],
                -width        => 12
                ),
            $namenscroll->Entry(
                -textvariable => \$mentor_tel[$i],
                -width        => 12
                ),
            $namenscroll->Entry(
                -textvariable => \$mentor_email[$i],
                -width        => 12
                ),
            $namenscroll->Entry(
                -textvariable => \$mentor_adresse[$i],
                -width        => 12
                ),
                )
    };

    my $button;
    $button = $namen->Show();

    if ( $button eq "Neuer Schüler" ) {
        $mentor_schuelerzahl ++;
        &persoenliche_daten;
    }
    elsif ( $button eq "Sortieren" ) {
        &schueler_sortieren;
        &persoenliche_daten;
    }
}

sub schueler_sortieren {

    # Sicherungskopie anlegen:
    open DATEI, ">>.testimonium_sicherungskopie";
    printf DATEI "XXXXX Schüler alphabetisch sortiert: $filename \n";
    &daten_schreiben;
    printf DATEI
        "XXXXX -------------------------------------------------------------------------------------------------------------\n";
    close DATEI;

    my @sorted_indices = sort nach_name_vorname_gebdatum 0 .. $#mentor_nachname;

    sub nach_name_vorname_gebdatum {
        $mentor_nachname[$a] cmp $mentor_nachname[$b]
            or $mentor_vorname[$a] cmp $mentor_vorname[$b]
            or $mentor_geburtsdatum[$a] cmp $mentor_geburtsdatum[ $b ]    # dient nur der eindeutigen Unterscheidung, sortierung so nicht sonnvoll...
    }

    @mentor_nachname     = @mentor_nachname[@sorted_indices];
    @mentor_vorname      = @mentor_vorname[@sorted_indices];
    @mentor_geburtsdatum = @mentor_geburtsdatum[@sorted_indices];
    @mentor_konfession   = @mentor_konfession[@sorted_indices];
    @mentor_adresse      = @mentor_adresse[@sorted_indices];

    # fünfdimensionale Felder: blubb(schueler)(fach)(stufe)(halbjahr)(nr)
    @mentor_klassenarbeiten     = @mentor_klassenarbeiten[@sorted_indices];
    @mentor_tests               = @mentor_tests[@sorted_indices];
    @mentor_hausaufgaben        = @mentor_hausaufgaben[@sorted_indices];
    @mentor_ha_da               = @mentor_ha_da[@sorted_indices];       # jeweils frisch berechnen, nur für (schueler)
    @mentor_ha_fehlt            = @mentor_ha_fehlt[@sorted_indices];    # ....
    @mentor_mitarbeit           = @mentor_mitarbeit[@sorted_indices];
    @mentor_heft                = @mentor_heft[@sorted_indices];
    @mentor_abfrage             = @mentor_abfrage[@sorted_indices]; 

    # dreidimensional: blubb (schueler)(fach)(stufe)
    @mentor_mitarbeit_errechnet = @mentor_mitarbeit_errechnet[@sorted_indices];
    @mentor_mitarbeit_gegeben   = @mentor_mitarbeit_gegeben[@sorted_indices];
    @mentor_verhalten_gegeben   = @mentor_verhalten_gegeben[@sorted_indices];
    @mentor_hjz_errechnet       = @mentor_hjz_errechnet[@sorted_indices];
    @mentor_hjz_gegeben         = @mentor_hjz_gegeben[@sorted_indices];
    @mentor_jz_errechnet        = @mentor_jz_errechnet[@sorted_indices];
    @mentor_jz_gegeben          = @mentor_jz_gegeben[@sorted_indices];

};

sub notenuebersicht {
    &hausaufgaben_zaehlen;
    my $noten = $main->DialogBox(
      -title   => "Notenübersicht",
      -buttons => [ "OK", "Liste drucken", "Import"]
    );

    my $notenscroll =
        $noten->Scrolled( "Frame", -scrollbars => "oe", -height => "500" )->pack( -fill => "both", -expand => "1" );

    $notenscroll->Label( -text => "Nr." )->grid(
        $notenscroll->Label( -text => "Nachname" ),
        $notenscroll->Label( -text => "Vorname" ),
        $notenscroll->Label( -text => "1. KA" ),
        $notenscroll->Label( -text => "2. KA" ),
        $notenscroll->Label( -text => "3. KA" ),
        $notenscroll->Label( -text => "Test 1" ),
        $notenscroll->Label( -text => "Test 2" ),
        $notenscroll->Label( -text => "Test 3" ),
        $notenscroll->Label( -text => "Test 4" ),
        $notenscroll->Label( -text => "Heft" ),
        $notenscroll->Label( -text => "m. Abfrage" ),
        $notenscroll->Label( -text => "Mitarbeit" ),
        $notenscroll->Label( -text => "HA da" ),
        $notenscroll->Label( -text => "HA fehlt" ),        
        );

    for ( my $i = 1; $i <= $mentor_schuelerzahl; $i++ ) {
        $notenscroll->Label( -text => "$i :" )->grid(
            $notenscroll->Entry(
                -textvariable => \$mentor_nachname[$i],
                -width        => 15
            ),
            $notenscroll->Entry(
                -textvariable => \$mentor_vorname[$i],
                -width        => 15
            ),
#blubb(schueler)(fach)(stufe)(halbjahr)(nr)
            $notenscroll->Entry(
                -textvariable => \$mentor_klassenarbeiten[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][1],
                -width        => 5
                ),
           $notenscroll->Entry(
                -textvariable => \$mentor_klassenarbeiten[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][2],
                -width        => 5
                ),
            $notenscroll->Entry(
                -textvariable => \$mentor_klassenarbeiten[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][3],
                -width        => 5
                ),
            $notenscroll->Entry(
                -textvariable => \$mentor_tests[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][1],
                -width        => 5
                ),
            $notenscroll->Entry(
                -textvariable => \$mentor_tests[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][2],
                -width        => 5
                ),
            $notenscroll->Entry(
                -textvariable => \$mentor_tests[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][3],
                -width        => 5
                ),
            $notenscroll->Entry(
                -textvariable => \$mentor_tests[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][4],
                -width        => 5
                ),
           $notenscroll->Entry(
                -textvariable => \$mentor_heft[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][1],
                -width        => 5
                ),
            $notenscroll->Entry(
                -textvariable => \$mentor_abfrage[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][1],
                -width        => 5
                ),
            $notenscroll->Entry(
                -textvariable => \$mentor_mitarbeit[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][1],
                -width        => 5
                ),
            $notenscroll -> Label (-textvariable => \$mentor_ha_da[$i]),
            $notenscroll -> Label (-textvariable => \$mentor_ha_fehlt[$i]),

                )
    };

    my $button;
    $button = $noten->Show();

    if ( $button eq "Liste drucken" ) {
        &liste_drucken;
    }     
    elsif ($button eq "Import" ) {
        &note_importieren;
    }
};


sub liste_drucken {
};


sub note_importieren {
};


sub hausaufgaben {
  my $ha = $main->DialogBox(
      -title   => "Notenübersicht",
      -buttons => [ "OK"]
  );

    my $hascroll =
        $ha -> Scrolled( "Frame", -scrollbars => "oe", -height => "500" )->pack( -fill => "both", -expand => "1" );

    $hascroll->Label( -text => "Nr." )->grid(
        $hascroll->Label( -text => "Nachname" ),
        $hascroll->Label( -text => "Vorname" ),
        $hascroll->Label( -text => "1" ),
        $hascroll->Label( -text => "2" ),
        $hascroll->Label( -text => "3" ),
        $hascroll->Label( -text => "4" ),
        $hascroll->Label( -text => "5" ),
        $hascroll->Label( -text => "6" ),
        $hascroll->Label( -text => "7" ),
        $hascroll->Label( -text => "8" ),
        $hascroll->Label( -text => "9" ),
        $hascroll->Label( -text => "10" ),
        $hascroll->Label( -text => "11" ),
        $hascroll->Label( -text => "12" ),
        $hascroll->Label( -text => "13" ),
        $hascroll->Label( -text => "14" ),
        $hascroll->Label( -text => "15" ),
        $hascroll->Label( -text => "16" ),
        $hascroll->Label( -text => "17" ),
        $hascroll->Label( -text => "18" ),
        $hascroll->Label( -text => "19" ),
        $hascroll->Label( -text => "20" ),
        $hascroll->Label( -text => "21" ),
        $hascroll->Label( -text => "22" ),
        $hascroll->Label( -text => "23" ),
        $hascroll->Label( -text => "24" ),
        );
    
        $hascroll->Label (-text => "Datum der Hausaufgabe:") -> grid("-", "-",
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][1], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][2], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][3], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][4], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][5], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][6], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][7], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][8], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][9], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][10], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][11], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][12], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][13], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][14], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][15], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][16], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][17], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][18], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][19], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][20], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][21], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][22], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][23], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[0]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][24], -width => 2),
        );
    
    for ( my $i = 1; $i <= $mentor_schuelerzahl; $i++ ) {
        $hascroll->Label( -text => "$i :" )->grid(
            $hascroll->Label( -text => "$mentor_nachname[$i]" ),
            $hascroll->Label( -text => "$mentor_vorname[$i]" ),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][1], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][2], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][3], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][4], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][5], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][6], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][7], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][8], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][9], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][10], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][11], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][12], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][13], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][14], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][15], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][16], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][17], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][18], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][19], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][20], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][21], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][22], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][23], -width => 2),
            $hascroll->Entry(-textvariable => \$mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][24], -width => 2),
        )
        
        };
   
   
    my $button;
    $button = $ha->Show();

    if ( $button eq "Neuer Schüler" ) {
        push @mentor_nachname;
        &persoenliche_daten;
    }
    elsif ( $button eq "Sortieren" ) {
        &schueler_sortieren;
        &persoenliche_daten;
    }
    
    &hausaufgaben_zaehlen;

};

sub hausaufgaben_zaehlen {
    for ( my $i = 1; $i <= $mentor_schuelerzahl; $i++ ) {
        $mentor_ha_da[$i] = 0;
        $mentor_ha_fehlt[$i] = 0;
        for (my $j = 1; $j <= 24; $j++ ) {
            if ($mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][$j] eq "+") {
                $mentor_ha_da[$i] ++;
            }
            elsif ($mentor_hausaufgaben[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][$j] eq "-") {
                $mentor_ha_fehlt[$i] ++;
            }
        };
    };
};


sub zeugnisnoten {
    &hausaufgaben_zaehlen;
    if ( $mentor_hj eq "1" ) {
        &halbjahreszeugnis;
    }
    else {
        &jahreszeugnis;
    };
};


sub halbjahreszeugnis {
    &durchschnitte_berechnen;
    our @durchschnitt_ka;
    our @durchschnitt_tests;
    our @hausaufgabennote;

    &zeugnisnotenfenster_oeffnen;
    
    our $zscroll;
    $zscroll    ->Label( -text => "Nr." )->grid(
        $zscroll->Label( -text => "Nachname" ),
        $zscroll->Label( -text => "Vorname" ),
        $zscroll->Label( -text => "Heft" ),
        $zscroll->Label( -text => "m. Abfrage" ),
        $zscroll->Label( -text => "Mitarbeit" ),
        $zscroll->Label( -text => "HA-Note" ),    
        $zscroll->Label( -text => "KA-Durchschnitt" ),
        $zscroll->Label( -text => "Test-Durchschnitt"),
        $zscroll->Label( -text => "Gesamt-Durchschnitt" ),
        $zscroll->Label( -text => "Endnote" ),
        $zscroll->Label( -text => "Verhalten" ),
        $zscroll->Label( -text => "Mitarbeit" ),
    );
    
    for ( my $i = 1; $i <= $mentor_schuelerzahl; $i++ ) {
        $zscroll->Label( -text => "$i :" )->grid(
            $zscroll->Label( -text => "$mentor_nachname[$i]" ),
            $zscroll->Label( -text => "$mentor_vorname[$i]" ),
            $zscroll->Label( -text => "heft" ),
            $zscroll->Label( -text => "abfrage" ),
            $zscroll->Label( -text => "mitarbeit" ),
            $zscroll->Label( -text => "ha-note" ),
            $zscroll->Label( -textvariable => \$durchschnitt_ka[$i] ),
            $zscroll->Label( -textvariable => \$durchschnitt_tests[$i] ),
            $zscroll->Label( -text => "ges." ),
            $zscroll->Entry( -textvariable => \$mentor_hjz_gegeben[$i], -width => "5" ),
            $zscroll->Entry( -textvariable => \$mentor_verhalten_gegeben[$i], -width => "5" ),
            $zscroll->Entry( -textvariable => \$mentor_mitarbeit_gegeben[$i], -width => "5" ),
        );
    };

    &zeugnisnotenfenster_buttons;
};


sub jahreszeugnis {
    &durchschnitte_berechnen;
    our @durchschnitt_ka;
    our @durchschnitt_tests;
    our @hausaufgabennote;

    &zeugnisnotenfenster_oeffnen;
};


sub durchschnitte_berechnen {
    # Klassenarbeiten:
    our @durchschnitt_ka;
    for ( my $i = 1; $i <= $mentor_schuelerzahl; $i++ ) {
        my $ka_summe;
        my $ka_zaehler;
        for ( my $j = 1; $j <= 3; $j++ ) {
            if ($mentor_klassenarbeiten[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][$j] ne "-" and
                $mentor_klassenarbeiten[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][$j] ne "" ) {
                $ka_summe = $ka_summe + $mentor_klassenarbeiten[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][$j];
                $ka_zaehler++;
            };
        };
        if ( ! $ka_zaehler == 0 ) {
            @durchschnitt_ka[$i] = $ka_summe / $ka_zaehler;
        }
        else {
            @durchschnitt_ka[$i] = "-";
        };
    };
    
    # Tests:
    our @durchschnitt_tests;
    for ( my $i = 1; $i <= $mentor_schuelerzahl; $i++ ) {
        my $test_summe;
        my $test_zaehler;
        for ( my $j = 1; $j <= 4; $j++ ) {
            if ($mentor_tests[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][$j] ne "-" and
                $mentor_tests[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][$j] ne "" ) {
                $test_summe = $test_summe + $mentor_tests[$i]{$mentor_welches_fach}[$mentor_stufe][$mentor_hj][$j];
                $test_zaehler++;
            };
        };
        if ( ! $test_zaehler == 0 ) {
            @durchschnitt_tests[$i] = $test_summe / $test_zaehler;
        }
        else {
            @durchschnitt_tests[$i] = "-";
        };
    };
    
    # Hausaufgabennote:
    our @hausaufgabennote;
    for ( my $i = 1; $i <= $mentor_schuelerzahl; $i++ ) {
    };
    
    # Gesamtdurchschnitt (gemäß Gewichtung):
    our @gesamtdurchschnitt;
    for ( my $i = 1; $i <= $mentor_schuelerzahl; $i++ ) {
        if ( $mentor_hj eq "1" ) {
        }
        else {
        }
    };
};


sub gewichtung_definieren {
    my $summe_prozentsaetze;
    
    my $gewichtung = $main->DialogBox(
        -title   => "Gewichtung für Durchschnittsberechnung",
        -buttons => [ "OK"]
    );
    
    $gewichtung -> Label( -text => "1. Innerhalb eines Halbjahres:" )->grid();
    $gewichtung -> Label( -text => "Prozentsatz der Klassenarbeiten" )->grid(
    $gewichtung -> Entry( -textvariable => \$prozentsatz_klassenarbeiten )
    );
    $gewichtung -> Label( -text => "Prozentsatz der Tests" )->grid(
    $gewichtung -> Entry( -textvariable => \$prozentsatz_tests )
    );
    $gewichtung -> Label( -text => "Prozentsatz der mündl. Abfrage" )->grid(
    $gewichtung -> Entry( -textvariable => \$prozentsatz_abfrage )
    );
    $gewichtung -> Label( -text => "Prozentsatz der Heftnote" )->grid(
    $gewichtung -> Entry( -textvariable => \$prozentsatz_heftnote )
    );
    $gewichtung -> Label( -text => "Prozentsatz der Hausaufgaben" )->grid(
    $gewichtung -> Entry( -textvariable => \$prozentsatz_hausaufgaben )
    );
    $gewichtung -> Label( -text => "Summe (Soll: 100)" )->grid(
    $gewichtung -> Label( -textvariable => \$summe_prozentsaetze )
    );
    
    $gewichtung -> Label( -text => "2. Verhältnis der Halbjahre:" )->grid();
    $gewichtung -> Label( -text => "Prozentsatz der Note des 1. Halbjahres" )->grid();
    
    my $button = $gewichtung -> Show();
    &zeugnisnoten;
};


sub zeugnisnotenfenster_oeffnen {
    our $zeugnis = $main->DialogBox(
        -title   => "Notenübersicht",
        -buttons => [ "OK", "Gewichtung definieren"]
    );

    our $zscroll =
        $zeugnis->Scrolled( "Frame", -scrollbars => "oe", -height => "500" )->pack( -fill => "both", -expand => "1" );
};


sub zeugnisnotenfenster_buttons {
    my $button;
    $button = our $zeugnis -> Show();

    if ( $button eq "Gewichtung definieren" ) {
        &gewichtung_definieren;
    }
};


sub laden {
  $filename = $main -> getOpenFile ( -title => "Zensur laden", -filetypes => [ ["capra:mentor-Dateien", [".txm"] ], 
                                                                                  ["alle Dateien",      ["*"]    ] ] );

  if ($filename) {
    open CONFIG, "$filename" or die "*** Datei nicht gefunden! \n";
      undef $/;
      eval <CONFIG> || print "*** Kann Datei nicht auswerten! \n $@";
#LoadFile ($filename);
     close CONFIG;
  };
};


sub speichern {
  my $speichern = $main -> DialogBox ( -title => "Notenbüchlein abspeichern",
                                       -buttons => ["OK"]);
  $speichern -> Label ( -text => "Dateiname mit der Endung .txm versehen! \n Entweder volle Pfadangabe oder nur Dateiname im aktuellen Verzeichnis möglich. \n Dateiname:") -> pack();
  my $scr_filename = $speichern -> add ("Entry", -text => "$filename", -width => 50) -> pack();
  $speichern -> Show();

 $filename = $scr_filename -> get;

 open CONFIG, ">$filename";
    &daten_schreiben;
 close CONFIG;
};


sub daten_schreiben_kaese {
    DumpFile ($filename, $mentor_schuelerzahl, @mentor_nachname);
};

sub daten_schreiben {
   printf CONFIG Data::Dumper->Dump([$mentor_klasse], ['*mentor_klasse']);
   printf CONFIG Data::Dumper->Dump([$mentor_stufe], ['*mentor_stufe']);
   printf CONFIG Data::Dumper->Dump([$mentor_schuelerzahl], ['*mentor_schuelerzahl']);
   printf CONFIG Data::Dumper->Dump([$mentor_s], ['*mentor_s']);
   printf CONFIG Data::Dumper->Dump([$mentor_hj], ['*mentor_hj']);
   printf CONFIG Data::Dumper->Dump([$mentor_welches_fach], ['*mentor_welches_fach']);

   printf CONFIG Data::Dumper->Dump([\@mentor_nachname], ['*mentor_nachname']);
   printf CONFIG Data::Dumper->Dump([\@mentor_vorname], ['*mentor_vorname']);
   printf CONFIG Data::Dumper->Dump([\@mentor_tel], ['*mentor_tel']);
   printf CONFIG Data::Dumper->Dump([\@mentor_email], ['*mentor_email']);
   printf CONFIG Data::Dumper->Dump([\@mentor_geburtsdatum], ['*mentor_geburtsdatum']);
   printf CONFIG Data::Dumper->Dump([\@mentor_anrede], ['*mentor_anrede']);
   printf CONFIG Data::Dumper->Dump([\@mentor_konfession], ['*mentor_konfession']);
   printf CONFIG Data::Dumper->Dump([\@mentor_adresse], ['*mentor_adresse']);

# fünfdimensionale Felder: blubb(schueler)(fach)(stufe)(halbjahr)(nr)
   printf CONFIG Data::Dumper->Dump([\@mentor_klassenarbeiten], ['*mentor_klassenarbeiten']);
   printf CONFIG Data::Dumper->Dump([\@mentor_tests], ['*mentor_tests']);
   printf CONFIG Data::Dumper->Dump([\@mentor_hausaufgaben], ['*mentor_hausaufgaben']);
   printf CONFIG Data::Dumper->Dump([\@mentor_ha_da], ['*mentor_ha_da']);
   printf CONFIG Data::Dumper->Dump([\@mentor_ha_fehlt], ['*mentor_ha_fehlt']);
   printf CONFIG Data::Dumper->Dump([\@mentor_mitarbeit], ['*mentor_mitarbeit']);
   printf CONFIG Data::Dumper->Dump([\@mentor_heft], ['*mentor_heft']);
   printf CONFIG Data::Dumper->Dump([\@mentor_abfrage], ['*mentor_abfrage']);

# dreidimensional: blubb (schueler)(fach)(stufe)
   printf CONFIG Data::Dumper->Dump([\@mentor_mitarbeit_errechnet], ['*mentor_mitarbeit_errechnet']);
   printf CONFIG Data::Dumper->Dump([\@mentor_mitarbeit_gegeben], ['*mentor_mitarbeit_gegeben']);
   printf CONFIG Data::Dumper->Dump([\@mentor_verhalten_gegeben], ['*mentor_verhalten_gegeben']);
   printf CONFIG Data::Dumper->Dump([\@mentor_hjz_errechnet], ['*mentor_hjz_errechnet']);
   printf CONFIG Data::Dumper->Dump([\@mentor_hjz_gegeben], ['*mentor_hjz_gegeben']);
   printf CONFIG Data::Dumper->Dump([\@mentor_jz_errechnet], ['*mentor_jz_errechnet']);
   printf CONFIG Data::Dumper->Dump([\@mentor_jz_gegeben], ['*mentor_jz_gegeben']);   
};


sub beenden {
    exit;
};


sub programminfo {
    my $info = $main->DialogBox(
        -title   => "Über capra:mentor",
        -buttons => ["OK"]
    );

    $info->Label( -text => "$mentor_programmversion_prog\n Das Notenbüchlein für saarländische GemSen" )->grid();
    $info->Label( -text => "(c) 2015 Thomas Hilarius Meyer" )->grid();
    $info->Label( -text => "thomas.hilarius.meyer\@gmail.com" )->grid();
    $info->Show();
};
