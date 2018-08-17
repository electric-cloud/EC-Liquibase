@::gMatchers = (
  #liquibase common exception
  {
    id      => "liquibase-exception",
    pattern => q{liquibase.exception.(\w+): (.*)},
    action  => q{
      addSimpleMessage("liquibase-error", "Exception $1: $2");
      setProperty("outcome", "error" );
      updateSummary();
    }
  },
  #liquibase not found
  {
    id      => "liquibase-error",
    pattern => q{not found},
    action  => q{
      addSimpleMessage("liquibase-error", "Liquibase not found");
      setProperty("outcome", "error" );
      updateSummary();
    }
  },
  # warnings
  {
    id      => "liquibase-warning",
    pattern => q{warning:(.*?)$},
    action  => q{
      addSimpleMessage("liquibase-warning", "Warning: $1");
      setProperty("outcome", "warning" );
      updateSummary();},
  },
);

sub addSimpleMessage {
    my ($name, $customError) = @_;
    if(!defined $::gProperties{$name}){
        setProperty ($name, $customError);
    }
}

sub updateSummary {
    my $summary = (defined $::gProperties{"liquibase-error"}) ?
      $::gProperties{"liquibase-error"} . "\n" :
      "";
    setProperty ("summary", $summary);
}
