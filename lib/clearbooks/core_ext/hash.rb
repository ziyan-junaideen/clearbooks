#!/usr/bin/env ruby


# @class        class Hash
# @brief
class Hash

  # @fn         def except *keys {{{
  # @brief      Deletes specified keys from hash copy and returns it
  # @credit     https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/hash/except.rb
  def except(*keys)
    copy = self.dup
    keys.each { |key| copy.delete(key) }
    copy
  end #}}}

  # @fn         def compact {{{
  # @brief      Deletes keys with +nil+ values from hash copy and returns it
  def compact
    delete_if { |k, v| v.nil? }
  end # }}}

  # @fn         def savon key {{{
  # @brief      Savon shortcut to get attributes via :key or :@key
  def savon(key)
    v = self[key] || self["@#{(key.to_s)}".to_sym]
    if (v.is_a? Hash)
      v.from_savon
    else
      v
    end
  end #}}}

  # @fn         def from_savon {{{
  # @brief      Translates ":@key" savon attribute keys to ":key"
  def from_savon
    self.reduce({}) do |hash, (k, v)|
      k = k.to_s
      k = k[1..-1] if k.start_with? '@'
      hash[k.to_sym] = v
      hash
    end
  end
end
