COLLEGE_AND_DEPARTMENT = YAML.load( File.open( Rails.root.join( 'config/college_and_department.yml' ) ) ).freeze if File.exist?(Rails.root.join( 'config/college_and_department.yml'))
