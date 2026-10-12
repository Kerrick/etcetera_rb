# frozen_string_literal: true

require "test_helper"

class TestAppStrategyArgs < Minitest::Test
  include EtceteraTest

  def test_reexported_at_the_root
    assert_same Etcetera::AppStrategy::AppStrategyArgs, Etcetera::AppStrategyArgs
  end

  def test_bundle_id
    assert_equal "org.acme-corp.Frobnicator-Plus", acme_args.bundle_id
  end

  def test_unixy_name
    assert_equal "frobnicator-plus", acme_args.unixy_name
  end

  def test_bundle_id_drops_empty_parts
    args = Etcetera::AppStrategyArgs.new(
      top_level_domain: "",
      author: "",
      app_name: "Frobnicator Plus"
    )

    assert_equal "Frobnicator-Plus", args.bundle_id
  end

  def test_bundle_id_with_only_an_author
    args = Etcetera::AppStrategyArgs.new(
      top_level_domain: "",
      author: "Acme Corp",
      app_name: ""
    )

    assert_equal "acme-corp", args.bundle_id
  end

  def test_members_are_readable
    assert_equal "org", acme_args.top_level_domain
    assert_equal "Acme Corp", acme_args.author
    assert_equal "Frobnicator Plus", acme_args.app_name
  end

  # The crate derives Default, so every field defaults to an empty string.
  def test_keywords_default_to_empty_strings
    assert_equal Etcetera::AppStrategyArgs.new(top_level_domain: "", author: "", app_name: ""),
                 Etcetera::AppStrategyArgs.new
  end

  def test_value_semantics
    assert_equal acme_args, acme_args
    assert_equal acme_args.hash, acme_args.hash
    assert_operator Etcetera::AppStrategyArgs.new(top_level_domain: "com"), :<, acme_args
  end
end
