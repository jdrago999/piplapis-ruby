require_relative '../helper'


describe Pipl::Client::SearchResponse do

  it 'initializes with no params' do
    response = Pipl::Client::SearchResponse.new
    expect(response.query).to be_nil
    expect(response.person).to be_nil
    expect(response.sources).to be_nil
    expect(response.possible_persons).to be_nil
    expect(response.warnings).to be_nil
    expect(response.visible_sources).to be_nil
    expect(response.available_sources).to be_nil
    expect(response.search_id).to be_nil
    expect(response.http_status_code).to be_nil
  end

  it 'initializes with params' do
    query = Pipl::Person.new(fields: [Pipl::Email.new(address: 'test@example.com')])
    person = Pipl::Person.new(fields: [
                                  Pipl::Email.new(address: 'test@example.com'),
                                  Pipl::Name.new(first: 'first', last: 'last'),
                              ])
    sources = [
        Pipl::Source.new(name: 'source1'),
        Pipl::Source.new(name: 'source2'),
    ]
    possible_persons = [
        Pipl::Person.new(fields: [Pipl::Email.new(address: 'test1@example.com')]),
        Pipl::Person.new(fields: [Pipl::Email.new(address: 'test2@example.com')]),
        Pipl::Person.new(fields: [Pipl::Email.new(address: 'test3@example.com')]),
    ]
    warnings = %w(warning1 warning2 warning3)

    search_id = 1
    http_status_code = 200

    params = {
        query: query,
        person: person,
        sources: sources,
        possible_persons: possible_persons,
        warnings: warnings,
        visible_sources: 50,
        available_sources: 70,
        search_id: 1,
        http_status_code: 200
    }

    response = Pipl::Client::SearchResponse.new params

    expect(response.query).to be query
    expect(response.person).to be person
    expect(response.sources).to be sources
    expect(response.possible_persons).to be possible_persons
    expect(response.warnings).to be warnings
    expect(response.visible_sources).to eq(50)
    expect(response.available_sources).to eq(70)
    expect(response.search_id).to eq(1)
    expect(response.http_status_code).to eq(200)
  end

  it 'creates instance from json' do
    json_str = fixture('test.json').read
    response = Pipl::Client::SearchResponse.from_json json_str
    expect(response.query.email.address).to eq('clark.kent@example.com')
    expect(response.query.email.address_md5).to eq('2610ee49440fe757e3cc4e46e5b40819')
    expect(response.person.id).to eq('41a6a386-fa23-41e4-aa3d-9b686ee9a645')
    expect(response.person.match).to eq(0.99766)
    expect(response.person.names.length).to eq(2)
    expect(response.person.emails.length).to eq(4)
    expect(response.person.phones.length).to eq(1)
    expect(response.person.usernames.length).to eq(2)
    expect(response.person.user_ids.length).to eq(1)
    expect(response.person.languages.length).to eq(1)
    expect(response.person.ethnicities.length).to eq(3)
    expect(response.person.origin_countries.length).to eq(1)
    expect(response.person.addresses.length).to eq(2)
    expect(response.person.jobs.length).to eq(2)
    expect(response.person.educations.length).to eq(2)
    expect(response.person.relationships.length).to eq(6)
    expect(response.person.images.length).to eq(2)
    expect(response.person.urls.length).to eq(4)
    expect(response.person.gender.content).to eq('male')
    expect(response.person.dob.age).to eq(28)

    expect(response.sources.length).to eq(2)
    expect(response.possible_persons).to be_nil
    expect(response.warnings).to be_nil
    expect(response.visible_sources).to eq(2)
    expect(response.available_sources).to eq(1)
    expect(response.http_status_code).to eq(200)
  end

  it 'creates instance from json - possible persons' do
    json_str = fixture('test2.json').read
    response = Pipl::Client::SearchResponse.from_json json_str
    expect(response.query.usernames.first.content).to eq('alison1958')
    expect(response.possible_persons.length).to eq(15)
    expect(response.sources.length).to eq(16)

    expect(response.person).to be_nil
    expect(response.warnings).to be_nil
    expect(response.visible_sources).to eq(16)
    expect(response.available_sources).to eq(16)
    expect(response.http_status_code).to eq(200)
  end

  it 'returns matching sources' do
    response = Pipl::Client::SearchResponse.new
    expect(response.matching_sources).to be_nil

    response = Pipl::Client::SearchResponse.new(sources: [
                                         Pipl::Source.new(name: 'source1', match: 1.0),
                                         Pipl::Source.new(name: 'source2', match: 0.0),
                                     ])
    expect(response.matching_sources.length).to eq(1)
  end

  it 'groups sources by domain' do
    response = Pipl::Client::SearchResponse.new
    expect(response.group_sources_by_domain).to be_nil

    response = Pipl::Client::SearchResponse.new(sources: [
                                                    Pipl::Source.new(domain: 'domain1'),
                                                    Pipl::Source.new(domain: 'domain1'),
                                                    Pipl::Source.new(domain: 'domain2'),
                                                    Pipl::Source.new(domain: 'domain3'),
                                                ])
    expect(response.group_sources_by_domain['domain1'].length).to eq(2)
    expect(response.group_sources_by_domain['domain2'].length).to eq(1)
    expect(response.group_sources_by_domain['domain3'].length).to eq(1)
  end

  it 'groups sources by category' do
    response = Pipl::Client::SearchResponse.new
    expect(response.group_sources_by_category).to be_nil

    response = Pipl::Client::SearchResponse.new(sources: [
                                                    Pipl::Source.new(category: 'category1'),
                                                    Pipl::Source.new(category: 'category1'),
                                                    Pipl::Source.new(category: 'category2'),
                                                    Pipl::Source.new(category: 'category3'),
                                                ])
    expect(response.group_sources_by_category['category1'].length).to eq(2)
    expect(response.group_sources_by_category['category2'].length).to eq(1)
    expect(response.group_sources_by_category['category3'].length).to eq(1)
  end

  it 'groups sources by match' do
    response = Pipl::Client::SearchResponse.new
    expect(response.group_sources_by_match).to be_nil

    response = Pipl::Client::SearchResponse.new(sources: [
                                                    Pipl::Source.new(match: 1.0),
                                                    Pipl::Source.new(match: 1.0),
                                                    Pipl::Source.new(match: 0.7),
                                                    Pipl::Source.new(match: 0.5),
                                                ])
    expect(response.group_sources_by_match[1.0].length).to eq(2)
    expect(response.group_sources_by_match[0.7].length).to eq(1)
    expect(response.group_sources_by_match[0.5].length).to eq(1)
  end

  it 'delegates job shorthands to person' do
    response = Pipl::Client::SearchResponse.new
    expect(response.job).to be_nil
  end

end

