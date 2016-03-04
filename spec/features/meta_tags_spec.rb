require 'spec_helper'

describe 'meta tags' do

  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }

  describe 'for articles only' do
    before do
      article = FactoryGirl.create(:public_article,
        abstract: 'Some text',
        issn: '1234-1234',
        journal_title: 'Journal of Foo')
      visit curation_concern_article_path(article)
    end
    it 'displays article-only fields' do
      #abstract
      tag_label = 'DC.Description'
      tag_value = 'Some text'
      tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
      expect(page).to have_css(tag, visible: false)

      tag_label = 'DC.Description.Abstract'
      tag_value = 'Some text'
      tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
      expect(page).to have_css(tag, visible: false)

      #issn
      tag_label = 'citation_issn'
      tag_value = '1234-1234'
      tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
      expect(page).to have_css(tag, visible: false)

      #journal_title
      tag_label = 'citation_journal_title'
      tag_value = 'Journal of Foo'
      tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
      expect(page).to have_css(tag, visible: false)
    end
  end

  describe 'for images only' do
    before do
      image = FactoryGirl.create(:public_image,
        material: 'cheesecloth',
        measurements: '300 yards')
      visit curation_concern_image_path(image)
    end

    it 'displays image-only fields' do
      tag_label = 'DC.Format.Medium'
      tag_value = 'cheesecloth'
      tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
      expect(page).to have_css(tag, visible: false)

      tag_label = 'DC.Format.Extent'
      tag_value = '300 yards'
      tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
      expect(page).to have_css(tag, visible: false)
    end
  end

  describe 'for generic works' do
    describe 'standard fields' do
      before do
        generic_work = FactoryGirl.create(:public_generic_work,
          bibliographic_citation: 'This is a citation',
          coverage_spatial: 'Cincinnati',
          coverage_temporal: '19th Century',
          ## creator: "The Creator" (set by factory)
          user: user,
          date_created: '2001-02-03',
          date_modified: Date.parse('2001-02-03'),
          date_uploaded: Date.parse('2001-02-03'),
          description: 'It was the best of times, it was the worst of times.',
          identifier: 'doi:foo1bar2',
          language: 'Esperanto',
          publisher: 'UC Press',
          requires: 'Adobe Reader',
          subject: 'cheese',
          title: 'The varieties of Cincinnati cheese' )

        visit curation_concern_generic_work_path(generic_work)
      end

      it 'displays fields for other works' do
        tag_label = 'DC.identifier.bibliographicCitation'
        tag_value = 'This is a citation'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Coverage'
        tag_value = 'Cincinnati'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Coverage.Spatial'
        tag_value = 'Cincinnati'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Coverage'
        tag_value = '19th Century'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Coverage.Spatial'
        tag_value = 'Cincinnati'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'author'
        tag_value = 'The Creator'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Creator'
        tag_value = 'The Creator'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'citation_author'
        tag_value = 'The Creator'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Date'
        tag_value = '2001-02-03'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Date.Created'
        tag_value = '2001-02-03'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'citation_date'
        tag_value = '2001-02-03'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'citation_publication_date'
        tag_value = '2001-02-03'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Date.Modified'
        tag_value = '2001-02-03'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Date.dateSubmitted'
        tag_value = '2001-02-03'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Description'
        tag_value = 'It was the best of times, it was the worst of times.'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Identifier'
        tag_value = 'doi:foo1bar2'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'citation_doi'
        tag_value = 'doi:foo1bar2'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Language'
        tag_value = 'Esperanto'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'citation_language'
        tag_value = 'Esperanto'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Publisher'
        tag_value = 'UC Press'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'citation_publisher'
        tag_value = 'UC Press'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Relation'
        tag_value = 'Adobe Reader'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Relation.Requires'
        tag_value = 'Adobe Reader'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Subject'
        tag_value = 'cheese'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'citation_keywords'
        tag_value = 'cheese'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'DC.Title'
        tag_value = 'The varieties of Cincinnati cheese'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        tag_label = 'citation_title'
        tag_value = 'The varieties of Cincinnati cheese'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)
      end
    end

    describe 'special fields' do
      let(:work) do
        generic_work = FactoryGirl.create(:public_generic_work,
          creator: "And Another Creator", user: user) ## in addition to "The Creator"
      end
      before { visit curation_concern_generic_work_path(work) }

      it 'handles multiple fields' do
        #for 'author'
        tag_label = 'author'
        tag_value = 'And Another Creator|The Creator'
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)

        #multiple fields for all others
        tag_label = 'DC.Creator'
        tag = "meta[name='#{tag_label}']"
        expect(page).to have_css(tag, visible: false, count: 2)
      end

      it 'displays the permalink as citation_public_url' do
        tag_label = 'citation_public_url'
        tag_value = Curate.permanent_url_for(work)
        tag = "meta[name='#{tag_label}'][content='#{tag_value}']"
        expect(page).to have_css(tag, visible: false)
      end
    end

    describe 'attach_files' do
      let(:work) do 
        FactoryGirl.create(:generic_work_with_files, user: user,
          visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
      end

      it 'displays meta_tags for attached pdfs' do
        GenericFile.any_instance.stub(:filename).and_return('File.pdf')
        visit curation_concern_generic_work_path(work)

        tag_label = 'citation_pdf_url'
        tag = "meta[name='#{tag_label}']"
        expect(page).to have_css(tag, visible: false, count: 3)
      end

      it 'does not display meta_tags for attached non-pdfs' do
        GenericFile.any_instance.stub(:filename).and_return('File.txt')
        visit curation_concern_generic_work_path(work)

        tag_label = 'citation_pdf_url'
        tag = "meta[name='#{tag_label}']"
        expect(page).to have_css(tag, visible: false, count: 0)
      end
    end
  end
end
