require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class WorldWriterTest < ActiveSupport::TestCase
  def world_writer(world_locations, id = 1)
    OpenStruct.new(id: id, gds_editor?: false,
                   departmental_editor?: false, world_editor?: false,
                   world_writer?: true, organisation: nil,
                   can_force_publish_anything?: false,
                   world_locations: world_locations || [])
  end

  include AuthorityTestHelper

  test 'can create a new document' do
    assert enforcer_for(world_writer(['hat land']), Document).can?(:create)
  end

  test 'can create a new edition' do
    assert enforcer_for(world_writer(['hat land']), Edition).can?(:create)
  end

  test 'can see an edition that is not access limited if it is about their location' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'can see an edition about their location that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = world_writer(['hat land', 'tie land'])
    user.stubs(:organisation).returns(org)
    edition = with_locations(limited_publication([org]), ['shirt land', 'hat land'])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an edition about their locaiton that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = world_writer(['hat land', 'tie land'])
    user.stubs(:organisation).returns(org1)
    edition = with_locations(limited_publication([org2]), ['shirt land', 'hat land'])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an edition that is not about their location' do
    user = world_writer(['tie land'])
    edition = with_locations(normal_edition, ['shirt land'])
    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to an edition they are not allowed to see' do
    user = world_writer(['tie land'])
    edition = with_locations(normal_edition, ['shirt land'])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test 'can create a new edition of a document that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:create)
  end

  test 'can make changes to an edition that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:update)
  end

  test 'can delete an edition that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:delete)
  end

  test 'can make a fact check request for a edition that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:make_fact_check)
  end

  test 'can view fact check requests on a edition that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:review_fact_check)
  end

  test 'cannot publish an edition that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    refute enforcer_for(user, edition).can?(:publish)
  end

  test 'cannot publish a scheduled edition' do
    refute enforcer_for(world_writer(['hat land']), with_locations(scheduled_edition, ['hat land'])).can?(:publish)
  end

  test 'cannot reject an edition that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    refute enforcer_for(user, edition).can?(:reject)
  end

  test 'cannot force publish an edition that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    refute enforcer_for(user, edition).can?(:force_publish)
  end

  test 'can force publish an edition not about their location if they can_force_publish_anything?' do
    user = world_writer(['hat land', 'tie land'])
    user.stubs(:can_force_publish_anything?).returns(true)
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:force_publish)
  end

  test 'can force publish an edition about their location that is limited to another org if they can_force_publish_anything?' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = world_writer(['hat land', 'tie land'])
    user.stubs(:organisation).returns(org1)
    user.stubs(:can_force_publish_anything?).returns(true)
    edition = with_locations(limited_publication([org2]), ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:force_publish)
  end

  test 'can force publish a limited access edition outside their location and org if they can_force_publish_anything?' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = world_writer(['hat land', 'tie land'])
    user.stubs(:organisation).returns(org1)
    user.stubs(:can_force_publish_anything?).returns(true)
    edition = with_locations(limited_publication([org2]), ['shirt land'])

    assert enforcer_for(user, edition).can?(:force_publish)
  end

  test 'cannot force publish a scheduled edition, even if they can_force_publish_anything?' do
    user = world_writer(['hat land', 'tie land'])
    user.stubs(:can_force_publish_anything?).returns(true)
    refute enforcer_for(user, with_locations(scheduled_edition, ['hat land'])).can?(:publish)
  end

  test 'can make editorial remarks that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:review_editorial_remark)
  end

  test 'cannot clear the "not reviewed" flag on editions about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    refute enforcer_for(user, edition).can?(:approve)
  end

  test 'can limit access to an edition that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:limit_access)
  end

  test 'cannot unpublish an edition that is about their location and not access limited' do
    user = world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_edition, ['shirt land', 'hat land'])

    refute enforcer_for(user, edition).can?(:unpublish)
  end
end
