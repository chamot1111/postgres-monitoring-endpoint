
local bit = require("pgmoon.bit")
local bxor = bit.bxor

local function xor_strings(a, b)
    local result
    do
    local _accum_0 = { }
    local _len_0 = 1
    for i = 1, #a do
        local x = a:byte(i)
        local y = b:byte(i)
        if not (x and y) then
        return nil
        end
        local _value_0 = string.char(bxor(x, y))
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
    end
    result = _accum_0
    end
    return table.concat(result)
end

local md5
if ngx then
  md5 = ngx.md5
elseif pcall(function()
  return require("openssl.digest")
end) then
  local openssl_digest = require("openssl.digest")
  local hex_char
  hex_char = function(c)
    return string.format("%02x", string.byte(c))
  end
  local hex
  hex = function(str)
    return (str:gsub(".", hex_char))
  end
  md5 = function(str)
    return hex(openssl_digest.new("md5"):final(str))
  end
elseif pcall(function()
  return require("crypto")
end) then
  local crypto = require("crypto")
  md5 = function(str)
    return crypto.digest("md5", str)
  end
else
  md5 = function()
    return error("Either luaossl (recommended) or LuaCrypto is required to calculate md5")
  end
end
local hmac_sha256
if GetCryptoHash then
  hmac_sha256 = function(key, str)
    return GetCryptoHash("SHA256", str, key)
  end
elseif pcall(function()
  return require("openssl.hmac")
end) then
  hmac_sha256 = function(key, str)
    local openssl_hmac = require("openssl.hmac")
    local hmac = assert(openssl_hmac.new(key, "sha256"))
    hmac:update(str)
    return assert(hmac:final())
  end
elseif pcall(function()
  return require("resty.openssl.hmac")
end) then
  hmac_sha256 = function(key, str)
    local openssl_hmac = require("resty.openssl.hmac")
    local hmac = assert(openssl_hmac.new(key, "sha256"))
    hmac:update(str)
    return assert(hmac:final())
  end
else
  hmac_sha256 = function()
    return error("Either GetCryptoHash, luaossl or resty.openssl is required to calculate hmac sha256 digest")
  end
end
local digest_sha256
if Sha256 then
  digest_sha256 = Sha256
elseif pcall(function()
  return require("openssl.digest")
end) then
  digest_sha256 = function(str)
    local digest = assert(require("openssl.digest").new("sha256"))
    digest:update(str)
    return assert(digest:final())
  end
elseif pcall(function()
  return require("resty.sha256")
end) then
  digest_sha256 = function(str)
    local digest = assert(require("resty.sha256"):new())
    digest:update(str)
    return assert(digest:final())
  end
elseif pcall(function()
  return require("resty.openssl.digest")
end) then
  digest_sha256 = function(str)
    local digest = assert(require("resty.openssl.digest").new("sha256"))
    digest:update(str)
    return assert(digest:final())
  end
else
  digest_sha256 = function()
    return error("Either Sha256, luaossl or resty.openssl is required to calculate sha256 digest")
  end
end
local kdf_derive_sha256
if Sha256 then
  kdf_derive_sha256 = function(password, salt, iterations)
    salt = DecodeBase64(salt)

    local function F(P, S, c, i)
          local U = GetCryptoHash("SHA256", S .. string.pack(">I4", i), P)
          local result = U
          for _ = 2, c do
              U = GetCryptoHash("SHA256", U, P)
              result = xor_strings(result, U)
          end
          return result
      end

      local result = F(password, salt, iterations, 1)
      return result
  end
elseif pcall(function()
  return require("openssl.kdf")
end) then
  kdf_derive_sha256 = function(str, salt, i)
    local openssl_kdf = require("openssl.kdf")
    local decode_base64
    decode_base64 = require("pgmoon.util").decode_base64
    salt = decode_base64(salt)
    local key, err = openssl_kdf.derive({
      type = "PBKDF2",
      md = "sha256",
      salt = salt,
      iter = i,
      pass = str,
      outlen = 32
    })
    if not (key) then
      return nil, "failed to derive pbkdf2 key: " .. tostring(err)
    end
    return key
  end
elseif pcall(function()
  return require("resty.openssl.kdf")
end) then
  kdf_derive_sha256 = function(str, salt, i)
    local openssl_kdf = require("resty.openssl.kdf")
    local decode_base64
    decode_base64 = require("pgmoon.util").decode_base64
    salt = decode_base64(salt)
    local key, err = openssl_kdf.derive({
      type = openssl_kdf.PBKDF2,
      md = "sha256",
      salt = salt,
      pbkdf2_iter = i,
      pass = str,
      outlen = 32
    })
    if not (key) then
      return nil, "failed to derive pbkdf2 key: " .. tostring(err)
    end
    return key
  end
else
  kdf_derive_sha256 = function()
    return error("Either Sha256, luaossl or resty.openssl is required to derive pbkdf2 key")
  end
end
local random_bytes
if GetRandomBytes then
  random_bytes = GetRandomBytes
elseif pcall(function()
  return require("openssl.rand")
end) then
  random_bytes = require("openssl.rand").bytes
elseif pcall(function()
  return require("resty.random")
end) then
  random_bytes = require("resty.random").bytes
elseif pcall(function()
  return require("resty.openssl.rand")
end) then
  random_bytes = require("resty.openssl.rand").bytes
else
  random_bytes = function()
    return error("Either luaossl or resty.openssl is required to generate random bytes")
  end
end
local x509_digest
if pcall(function()
  return require("openssl.x509")
end) then
  local x509 = require("openssl.x509")
  x509_digest = function(pem, hash_type)
    return x509.new(pem, "PEM"):digest(hash_type, "s")
  end
elseif pcall(function()
  return require("resty.openssl.x509")
end) then
  local x509 = require("resty.openssl.x509")
  x509_digest = function(pem, hash_type)
    return x509.new(pem, "PEM"):digest(hash_type)
  end
else
  x509_digest = function()
    return error("Either luaossl or resty.openssl is required to calculate x509 digest")
  end
end
return {
  md5 = md5,
  hmac_sha256 = hmac_sha256,
  digest_sha256 = digest_sha256,
  kdf_derive_sha256 = kdf_derive_sha256,
  random_bytes = random_bytes,
  x509_digest = x509_digest,
  xor_strings = xor_strings
}
