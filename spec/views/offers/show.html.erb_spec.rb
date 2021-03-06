require 'spec_helper'

RSpec.describe 'offers/show' do
  let(:organization) { Fabricate(:organization) }
  let(:member) { Fabricate(:member, organization: organization) }
  let(:offer) { Fabricate(:offer, user: member.user, organization: organization) }
  let(:destination_account) { Fabricate(:account) }

  before do
    allow(view).to receive(:admin?).and_return(false)
    allow(offer).to receive(:member).and_return(member)
  end

  context 'when the user is logged in' do
    let(:logged_user) { Fabricate(:user) }

    before do
      Fabricate(
        :member,
        organization: organization,
        user: logged_user
      )

      allow(view).to receive(:current_user).and_return(logged_user)
    end

    context 'when the current organization is the same as offer\'s organization' do
      before do
        allow(view).to receive(:current_organization) { offer.organization }
      end

      it 'renders a link to the transfer page' do
        assign :offer, offer
        assign :destination_account, destination_account
        render template: 'offers/show'

        expect(rendered).to have_link(
          t('offers.show.give_time_for'),
          href: new_transfer_path(
            id: offer.user.id,
            offer: offer.id,
            destination_account_id: destination_account.id
          )
        )
      end

      it 'displays offer\'s user details' do
        assign :offer, offer
        assign :destination_account, destination_account
        render template: 'offers/show'

        expect(rendered).to include(offer.user.email)
      end
    end

    context 'when the current organization is not the same as offer\'s organization' do
      let(:another_organization) { Fabricate(:organization) }

      before do
        Fabricate(
          :member,
          organization: another_organization,
          user: logged_user
        )

        allow(view).to receive(:current_organization) { another_organization }
      end

      it 'doesn\'t render a link to the transfer page' do
        assign :offer, offer
        render template: 'offers/show'

        expect(rendered).to_not have_link(
          t('offers.show.give_time_for'),
          href: new_transfer_path(
            id: offer.user.id,
            offer: offer.id,
            destination_account_id: destination_account.id
          )
        )
      end

      it 'doesn\'t display offer\'s user details' do
        assign :offer, offer
        assign :destination_account, destination_account
        render template: 'offers/show'

        expect(rendered).to_not include(offer.user.email)
      end

      it 'displays the offer\'s organization' do
        assign :offer, offer
        render template: 'offers/show'

        expect(rendered).to include(
          t('posts.show.info',
            type: offer.class.model_name.human,
            organization: offer.organization.name
           )
        )
      end
    end
  end

  context 'when the user is not logged in' do
    before do
      allow(view).to receive(:current_user).and_return(nil)
      allow(view).to receive(:current_organization).and_return(nil)
    end

    it 'does not render a link to the transfer page' do
      assign :offer, offer
      assign :destination_account, destination_account
      render template: 'offers/show'

      expect(rendered).not_to have_link(
        t('offers.show.give_time_for'),
        href: new_transfer_path(
          id: offer.user.id,
          offer: offer.id,
          destination_account_id: destination_account.id
        )
      )
    end

    it 'renders a link to the login page' do
      assign :offer, offer
      render template: 'offers/show'

      expect(rendered).to have_link(
        t('layouts.application.login'),
        href: new_user_session_path
      )
    end

    it 'displays the offer\'s organization' do
      assign :offer, offer
      render template: 'offers/show'

      expect(rendered).to include(
        t('posts.show.info',
          type: offer.class.model_name.human,
          organization: offer.organization.name
         )
      )
    end

    it 'doesn\'t display offer\'s user details' do
      assign :offer, offer
      assign :destination_account, destination_account
      render template: 'offers/show'

      expect(rendered).to_not include(offer.user.email)
    end
  end
end
