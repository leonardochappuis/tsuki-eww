function cropString(inputString, maxLength)
  if #inputString > maxLength then
      return inputString:sub(1, maxLength) .. "..."
  else
      return inputString
  end
end

return cropString