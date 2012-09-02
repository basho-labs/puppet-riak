node co-data {
  $os = $::operatingsystem ? {
    /(?i:ubuntu|debian)/ => 'debby',
    default           => 'other'
  }

  notify { "Using OS: $os": }
}
