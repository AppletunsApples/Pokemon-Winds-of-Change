#===============================================================================
# Format text
#===============================================================================
FORMATREGEXP = /<(\/?)(c|c2|c3|o|fn|br|fs|i|b|r|pg|pog|u|s|icon|item|img|ac|ar|al|outln|outln2)(\s*\=\s*([^>]*))?>/i #edited by IA

def getFormattedText(bitmap, xDst, yDst, widthDst, heightDst, text, lineheight = 32,
                     newlineBreaks = true, explicitBreaksOnly = false,
                     collapseAlignments = false)
  dummybitmap = nil
  if !bitmap || bitmap.disposed?   # allows function to be called with nil bitmap
    dummybitmap = Bitmap.new(1, 1)
    bitmap = dummybitmap
    return
  end
  if !bitmap || bitmap.disposed? || widthDst <= 0 || heightDst == 0 || text.length == 0
    return []
  end
  textchunks = []
  controls = []
#  oldtext = text
  while text[FORMATREGEXP]
    textchunks.push($~.pre_match)
    if $~[3]
      controls.push([$~[2].downcase, $~[4], -1, $~[1] == "/"])
    else
      controls.push([$~[2].downcase, "", -1, $~[1] == "/"])
    end
    text = $~.post_match
  end
  if controls.length == 0
    ret = getFormattedTextFast(bitmap, xDst, yDst, widthDst, heightDst, text, lineheight,
                               newlineBreaks, explicitBreaksOnly)
    dummybitmap&.dispose
    return ret
  end
  x = y = 0
  characters = []
  charactersInternal = []
#  realtext = nil
#  realtextStart = ""
#  if !explicitBreaksOnly && textchunks.join.length == 0
#    # All commands occurred at the beginning of the text string
#    realtext = (newlineBreaks) ? text : text.gsub(/\n/, " ")
#    realtextStart = oldtext[0, oldtext.length - realtext.length]
#  end
  textchunks.push(text)
  textchunks.each do |chunk|
    chunk.gsub!(/&lt;/, "<")
    chunk.gsub!(/&gt;/, ">")
    chunk.gsub!(/&apos;/, "'")
    chunk.gsub!(/&quot;/, "\"")
    chunk.gsub!(/&amp;/, "&")
  end
  textlen = 0
  controls.each_with_index do |control, i|
    textlen += textchunks[i].scan(/./m).length
    control[2] = textlen
  end
  text = textchunks.join
  textchars = text.scan(/./m)
  colorstack = []
  boldcount = 0
  italiccount = 0
  outlinecount = 0
  underlinecount = 0
  strikecount = 0
  rightalign = 0
  outline2count = 0
  opacitystack = []
  oldfont = bitmap.font.clone
  defaultfontname = bitmap.font.name
  defaultfontsize = bitmap.font.size
  fontsize = defaultfontsize
  fontnamestack = []
  fontsizestack = []
  defaultcolors = [oldfont.color.clone, nil]
  if defaultfontname.is_a?(Array)
    defaultfontname = defaultfontname.find { |i| Font.exist?(i) } || "Arial"
  elsif !Font.exist?(defaultfontname)
    defaultfontname = "Arial"
  end
  defaultfontname = defaultfontname.clone
  fontname = defaultfontname
  alignstack = []
  lastword = [0, 0] # position of last word
  hadspace = false
  hadnonspace = false
  havenl = false
  position = 0
  while position < textchars.length
    nextline = 0
    graphic = nil
    graphicX = 0
    graphicY = 4
    graphicWidth = nil
    graphicHeight = nil
    graphicRect = nil
    controls.length.times do |i|
      if controls[i] && controls[i][2] == position
        control = controls[i][0]
        param = controls[i][1]
        endtag = controls[i][3]
        case control
        when "c"
          if endtag
            colorstack.pop
          else
            color = rgbToColor(param)
            colorstack.push([color, nil])
          end
        when "c2"
          if endtag
            colorstack.pop
          else
            base = Rgb16ToColor(param[0, 4])
            shadow = Rgb16ToColor(param[4, 4])
            colorstack.push([base, shadow])
          end
        when "c3"
          if endtag
            colorstack.pop
          else
            param = param.split(",")
            # get pure colors unaffected by opacity
            oldColors = getLastParam(colorstack, defaultcolors)
            base = (param[0] && param[0] != "") ? rgbToColor(param[0]) : oldColors[0]
            shadow = (param[1] && param[1] != "") ? rgbToColor(param[1]) : oldColors[1]
            colorstack.push([base, shadow])
          end
        when "o"
          if endtag
            opacitystack.pop
          else
            opacitystack.push(param.sub(/\s+$/, "").to_i)
          end
        when "b"
          boldcount += (endtag ? -1 : 1)
        when "i"
          italiccount += (endtag ? -1 : 1)
        when "u"
          underlinecount += (endtag ? -1 : 1)
        when "s"
          strikecount += (endtag ? -1 : 1)
        when "outln"
          outlinecount += (endtag ? -1 : 1)
        when "outln2"
          outline2count += (endtag ? -1 : 1)
        when "fs" # Font size
          if endtag
            fontsizestack.pop
          else
            fontsizestack.push(param.sub(/\s+$/, "").to_i)
          end
          fontsize = getLastParam(fontsizestack, defaultfontsize)
          bitmap.font.size = fontsize
        when "fn" # Font name
          if endtag
            fontnamestack.pop
          else
            fontname = param.sub(/\s+$/, "")
            fontnamestack.push(Font.exist?(fontname) ? fontname : "Arial")
          end
          fontname = getLastParam(fontnamestack, defaultfontname)
          bitmap.font.name = fontname
        when "ar" # Right align
          if endtag
            alignstack.pop
          else
            alignstack.push(1)
          end
          nextline = 1 if x > 0 && nextline == 0
        when "al" # Left align
          if endtag
            alignstack.pop
          else
            alignstack.push(0)
          end
          nextline = 1 if x > 0 && nextline == 0
        when "ac" # Center align
          if endtag
            alignstack.pop
          else
            alignstack.push(2)
          end
          nextline = 1 if x > 0 && nextline == 0
        when "icon" # Icon
          if !endtag
            param = param.sub(/\s+$/, "")
            graphic = "Graphics/Icons/#{param}"
            controls[i] = nil
            break
          end
        when "item" # item (added by IA)
          if !endtag
            param = param.sub(/\s+$/, "")
            graphic = "Graphics/Items/#{param}"
            controls[i] = nil
            break
          end
        when "img" # Icon
          if !endtag
            param = param.sub(/\s+$/, "")
            param = param.split("|")
            graphic = param[0]
            if param.length > 1
              graphicX = param[1].to_i
              graphicY = param[2].to_i
              graphicWidth = param[3].to_i
              graphicHeight = param[4].to_i
            end
            controls[i] = nil
            break
          end
        when "br" # Line break
          if !endtag
            nextline += 1
          end
        when "r" # Right align this line
          if !endtag
            x = 0
            rightalign = 1
            lastword = [characters.length, x]
          end
        end
        controls[i] = nil
      end
    end
    bitmap.font.bold = (boldcount > 0)
    bitmap.font.italic = (italiccount > 0)
    if graphic
      if !graphicWidth
        tempgraphic = Bitmap.new(graphic)
        graphicWidth = tempgraphic.width
        graphicHeight = tempgraphic.height
        tempgraphic.dispose
      end
      width = graphicWidth   # +8  # No padding
      xStart = 0   # 4
      yStart = [(lineheight / 2) - (graphicHeight / 2), 0].max
      yStart += 4   # TEXT OFFSET
      graphicRect = Rect.new(graphicX, graphicY, graphicWidth, graphicHeight)
    else
      xStart = 0
      yStart = 0
      width = isWaitChar(textchars[position]) ? 0 : bitmap.text_size(textchars[position]).width
      width += 2 if width > 0 && outline2count > 0
    end
    if rightalign == 1 && nextline == 0
      alignment = 1
    else
      alignment = getLastParam(alignstack, 0)
    end
    nextline.times do
      havenl = true
      characters.push(["\n", x, (y * lineheight) + yDst, 0, lineheight, false, false, false,
                       defaultcolors[0], defaultcolors[1], false, false, "", 8, position, nil, 0])
      charactersInternal.push([alignment, y, 0])
      y += 1
      x = 0
      rightalign = 0
      lastword = [characters.length, x]
      hadspace = false
      hadnonspace = false
    end
    if textchars[position] == "\n"
      if newlineBreaks
        if nextline == 0
          havenl = true
          characters.push(["\n", x, (y * lineheight) + yDst, 0, lineheight, false, false, false,
                           defaultcolors[0], defaultcolors[1], false, false, "", 8, position, nil, 0])
          charactersInternal.push([alignment, y, 0])
          y += 1
          x = 0
        end
        rightalign = 0
        hadspace = true
        hadnonspace = false
        position += 1
        next
      else
        textchars[position] = " "
        if !graphic
          width = bitmap.text_size(textchars[position]).width
          width += 2 if width > 0 && outline2count > 0
        end
      end
    end
    isspace = (textchars[position][/\s/] || isWaitChar(textchars[position])) ? true : false
    if hadspace && !isspace
      # set last word to here
      lastword[0] = characters.length
      lastword[1] = x
      hadspace = false
      hadnonspace = true
    elsif isspace
      hadspace = true
    end
    texty = (lineheight * y) + yDst + yStart - 2   # TEXT OFFSET
    colors = getLastColors(colorstack, opacitystack, defaultcolors)
    # Push character
    if heightDst < 0 || texty < yDst + heightDst
      havenl = true if !graphic && isWaitChar(textchars[position])
      extraspace = (!graphic && italiccount > 0) ? 2 + (width / 2) : 2
      characters.push([graphic || textchars[position],
                       x + xStart, texty, width + extraspace, lineheight,
                       graphic ? true : false,
                       (boldcount > 0), (italiccount > 0), colors[0], colors[1],
                       (underlinecount > 0), (strikecount > 0), fontname, fontsize,
                       position, graphicRect,
                       ((outlinecount > 0) ? 1 : 0) + ((outline2count > 0) ? 2 : 0)])
      charactersInternal.push([alignment, y, xStart, textchars[position], extraspace])
    end
    x += width
    if !explicitBreaksOnly && x + 2 > widthDst && lastword[1] != 0 &&
       (!hadnonspace || !hadspace)
      havenl = true
      characters.insert(lastword[0], ["\n", x, (y * lineheight) + yDst, 0, lineheight,
                                      false, false, false,
                                      defaultcolors[0], defaultcolors[1],
                                      false, false, "", 8, position, nil])
      charactersInternal.insert(lastword[0], [alignment, y, 0])
      lastword[0] += 1
      y += 1
      x = 0
      (lastword[0]...characters.length).each do |i|
        characters[i][2] += lineheight
        charactersInternal[i][1] += 1
        extraspace = (charactersInternal[i][4]) ? charactersInternal[i][4] : 0
        charwidth = characters[i][3] - extraspace
        characters[i][1] = x + charactersInternal[i][2]
        x += charwidth
      end
      lastword[1] = 0
    end
    position += 1 if !graphic
  end
  # This code looks at whether the text occupies exactly two lines when
  # displayed. If it does, it balances the length of each line.
=begin
  # Count total number of lines
  numlines = (x==0 && y>0) ? y : y+1
  if numlines==2 && realtext && !realtext[/\n/] && realtext.length>=50
    # Set half to middle of text (known to contain no formatting)
    half = realtext.length/2
    leftSearch  = 0
    rightSearch = 0
    # Search left for a space
    i = half
    while i>=0
      break if realtext[i,1][/\s/]||isWaitChar(realtext[i,1])   # found a space
      leftSearch += 1
      i -= 1
    end
    # Search right for a space
    i = half
    while i<realtext.length
      break if realtext[i,1][/\s/]||isWaitChar(realtext[i,1])   # found a space
      rightSearch += 1
      i += 1
    end
    # Move half left or right whichever is closer
    trialHalf = half+((rightSearch<leftSearch) ? rightSearch : -leftSearch)
    if trialHalf!=0 && trialHalf!=realtext.length
      # Insert newline and re-call this function (force newlineBreaksOnly)
      newText = realtext.clone
      if isWaitChar(newText[trialHalf,1])
        # insert after wait character
        newText.insert(trialHalf+1,"\n")
      else
        # remove spaces after newline
        newText.insert(trialHalf,"\n")
        newText.gsub!(/\n\s+/,"\n")
      end
      bitmap.font = oldfont
      dummybitmap.dispose if dummybitmap
      return getFormattedText(dummybitmap ? nil : bitmap,xDst,yDst,
         widthDst,heightDst,realtextStart+newText,
         lineheight,true,explicitBreaksOnly)
    end
  end
=end
  if havenl
    # Eliminate spaces before newlines and pause character
    firstspace = -1
    characters.length.times do |i|
      if characters[i][5] != false # If not a character
        firstspace = -1
      elsif (characters[i][0] == "\n" || isWaitChar(characters[i][0])) &&
            firstspace >= 0
        (firstspace...i).each do |j|
          characters[j] = nil
          charactersInternal[j] = nil
        end
        firstspace = -1
      elsif characters[i][0][/[ \r\t]/]
        if firstspace < 0
          firstspace = i
        end
      else
        firstspace = -1
      end
    end
    if firstspace > 0
      (firstspace...characters.length).each do |j|
        characters[j] = nil
        charactersInternal[j] = nil
      end
    end
    characters.compact!
    charactersInternal.compact!
  end
  # Calculate Xs based on alignment
  # First, find all text runs with the same alignment on the same line
  totalwidth = 0
  widthblocks = []
  lastalign = 0
  lasty = 0
  runstart = 0
  characters.length.times do |i|
    c = characters[i]
    if i > 0 && (charactersInternal[i][0] != lastalign ||
       charactersInternal[i][1] != lasty)
      # Found end of run
      widthblocks.push([runstart, i, lastalign, totalwidth, lasty])
      runstart = i
      totalwidth = 0
    end
    lastalign = charactersInternal[i][0]
    lasty = charactersInternal[i][1]
    extraspace = (charactersInternal[i][4]) ? charactersInternal[i][4] : 0
    totalwidth += c[3] - extraspace
  end
  widthblocks.push([runstart, characters.length, lastalign, totalwidth, lasty])
  if collapseAlignments
    # Calculate the total width of each line
    totalLineWidths = []
    widthblocks.each do |block|
      y = block[4]
      if !totalLineWidths[y]
        totalLineWidths[y] = 0
      end
      if totalLineWidths[y] != 0
        # padding in case more than one line has different alignments
        totalLineWidths[y] += 16
      end
      totalLineWidths[y] += block[3]
    end
    # Calculate a new width for the next step
    widthDst = [widthDst, (totalLineWidths.compact.max || 0)].min
  end
  # Now, based on the text runs found, recalculate Xs
  widthblocks.each do |block|
    next if block[0] >= block[1]
    (block[0]...block[1]).each do |i|
      case block[2]
      when 1 then characters[i][1] = xDst + (widthDst - block[3] - 4) + characters[i][1]
      when 2 then characters[i][1] = xDst + ((widthDst / 2) - (block[3] / 2)) + characters[i][1]
      else        characters[i][1] = xDst + characters[i][1]
      end
    end
  end
  # Remove all characters with Y greater or equal to _yDst_+_heightDst_
  characters.delete_if { |ch| ch[2] >= yDst + heightDst } if heightDst >= 0
  bitmap.font = oldfont
  dummybitmap&.dispose
  return characters
end
