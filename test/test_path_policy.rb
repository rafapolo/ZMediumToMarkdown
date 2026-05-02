require 'minitest/autorun'
require_relative '../lib/PathPolicy'

class TestPathPolicy < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(@temp_dir) if Dir.exist?(@temp_dir)
  end

def test_init_with_absolute_and_relative_paths
    policy = PathPolicy.new("/tmp/output", "output")
    assert_equal "/tmp/output", policy.getAbsolutePath(nil)
    assert_equal "output/", policy.getRelativePath(nil)
  end

  def teardown
    FileUtils.rm_rf(@temp_dir) if Dir.exist?(@temp_dir)
  end

  def test_getAbsolutePath_with_subpath
    policy = PathPolicy.new("/tmp/output", "output")
    assert_equal "/tmp/output/subdir", policy.getAbsolutePath("subdir")
    assert_equal "output/subdir", policy.getRelativePath("subdir")
  end

  def test_getAbsolutePath_with_filename
    policy = PathPolicy.new("/tmp/output", "output")
    assert_equal "/tmp/output/file.md", policy.getAbsolutePath("file.md")
    assert_equal "output/file.md", policy.getRelativePath("file.md")
  end

  def test_handles_empty_string_subpath
    policy = PathPolicy.new("/tmp/output", "output")
    assert_equal "/tmp/output/", policy.getAbsolutePath("")
    assert_equal "output/", policy.getRelativePath("")
  end

  def test_getAbsolutePath_with_subpath
    policy = PathPolicy.new("/tmp/output", "output")
    assert_equal "/tmp/output/subdir", policy.getAbsolutePath("subdir")
    assert_equal "output/subdir", policy.getRelativePath("subdir")
  end

  def test_getAbsolutePath_with_filename
    policy = PathPolicy.new("/tmp/output", "output")
    assert_equal "/tmp/output/file.md", policy.getAbsolutePath("file.md")
    assert_equal "output/file.md", policy.getRelativePath("file.md")
  end

  def test_handles_empty_subpath
    policy = PathPolicy.new("/tmp/output", "output")
    assert_equal "/tmp/output/", policy.getAbsolutePath("")
    assert_equal "output/", policy.getRelativePath("")
  end
end