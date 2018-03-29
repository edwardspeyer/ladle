module Ladle
  module VCS
    def vcs_version
      `git log --oneline | wc -l`.strip.to_i
    end

    def vcs_modified?
      not `git status --porcelain`.strip.empty?
    end
  end
end
