requires "Const::Fast" => "0";
requires "Encode" => "0";
requires "Getopt::Long" => "2.36";
requires "HTML::Parser" => "0";
requires "List::Util" => "0";
requires "Moose" => "0";
requires "MooseX::NonMoose" => "0";
requires "Scalar::Util" => "0";
requires "Search::Tokenizer" => "0";
requires "Test::Builder::Module" => "0";
requires "Text::Aspell" => "0";
requires "curry" => "0";
requires "namespace::autoclean" => "0";
requires "perl" => "v5.10.0";

on 'test' => sub {
  requires "English" => "0";
  requires "File::Spec" => "0";
  requires "Module::Metadata" => "0";
  requires "Test::Builder::Tester" => "0";
  requires "Test::More" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CleanNamespaces" => "0.15";
  requires "Test::EOF" => "0";
  requires "Test::EOL" => "0";
  requires "Test::Kwalitee" => "1.21";
  requires "Test::MinimumVersion" => "0";
  requires "Test::More" => "0.88";
  requires "Test::NoTabs" => "0";
  requires "Test::Perl::Critic" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
  requires "Test::Pod::LinkCheck" => "0";
  requires "Test::Portability::Files" => "0";
  requires "Test::TrailingSpace" => "0.0203";
};
