=begin
Version: MPL 1.1/GPL 2.0/LGPL 2.1

"The contents of this file are subject to the Mozilla Public License Version
1.1 (the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is pdf_license, released June 5th, 2010. The Initial
Developer of the Original Code is consiliens (consiliens@gmail.com). Portions
created by consiliens are Copyright (C) 2010 consiliens
(consiliens@gmail.com). All Rights Reserved.

Alternatively, the contents of this file may be used under the terms of the
GNU Lesser General Public License Version 2.1 or later (the "LGPL" License),
in which case the provisions of the LGPL License are applicable instead of
those above. If you wish to allow use of your version of this file only under
the terms of the LGPL License and not to allow others to use your version of
this file under the MPL, indicate your decision by deleting the provisions
above and replace them with the notice and other provisions required by the
LGPL License. If you do not delete the provisions above, a recipient may use
your version of this file under either the MPL or the LGPL License."
=end
require 'java'
# http://anonsvn.icefaces.org/repo/maven2/releases/org/icepdf/icepdf-core/4.2.2/
require 'icepdf-core-4.2.2.jar'

include_class org.icepdf.core.pobjects.Document

class PdfLicense
  # Checks that the PDF contains at least one license string.
  # pdf_dir_glob - Dir.glob to search for PDF files
  # strings_to_match - Array of strings to match
  def initialize pdf_dir_glob, strings_to_match
    @pdf_dir_glob = pdf_dir_glob
    @strings_to_match = strings_to_match
  end

  def check
    document = Document.new
    pdf_paths = []

    # Use FNM_DOTMATCH to include hidden directories starting with '.'.
    Dir.glob @pdf_dir_glob, File::FNM_DOTMATCH do | pdf |
      # Dir.glob may not be case sensitive so check .pdf using Regexp
      pdf_paths.push File.expand_path pdf if pdf.match /pdf$/i
    end

    for pdf in pdf_paths
      begin
        document.file = pdf
        matched = false
        matched_string = ''
        
        for page_number in 0 .. document.number_of_pages
          page_text = document.page_text page_number
          next if page_text == nil || page_text.page_lines == nil
          page_text_string = page_text.to_s
          
          @strings_to_match.each do | match_string |
            if page_text_string.match match_string              
              matched = true
              matched_string = match_string
              break
            end
          end
            
          break if matched          
        end
        
        yield matched, pdf, matched_string
      rescue Exception => exception
        puts exception
      end
    end
  end
end
