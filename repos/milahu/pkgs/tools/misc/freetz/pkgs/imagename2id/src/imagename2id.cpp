// this tool is called REALLY often in the build process
// so it makes sense to implement it in native code

// translated by https://codingfleet.com/code-converter/bash/c++/
// from https://github.com/Freetz/freetz/raw/master/tools/imagename2id

// called from make/include/700-image.mk
// missing in freetz-ng

/*
#
# converts image filename to a much shorter but still unique character sequence (i.e. suitable to be used as id)
#

cat - \
| sed -r -e 's@.*_([0-9]{4}(_?sl|_?v[1-3]|_?lte|_16|_vDSL|_v3_Edition_Italia)?|fon|fon_wlan|fon_ata|sl_wlan)([._]?(beta|labor|labbeta))?([.]Annex[AB])?(([.]en|[.]int|[.]de|[.]it)(-en|-de|-es|-it|-fr|-pl|-nl)*)?([.][0-9]{2,3}[.]0[0-9][.][0-9]{2}(-[0-9]+)?)[.]image@\1\7\9@I' \
| sed -r -e 's@[.]image$@@' \
| tr '[:upper:]' '[:lower:]'
*/

#include <iostream>
#include <string>
#include <regex>
#include <algorithm>

const bool debug = false;
//const bool debug = true;

std::string convertImageFilenameToId(std::string filename) {

    debug && std::cerr << "filename: " << filename << std::endl;

    // Regular expressions to match patterns in the filename
    std::regex pattern1(".*_([0-9]{4}(_?sl|_?v[1-3]|_?lte|_16|_vDSL|_v3_Edition_Italia)?|fon|fon_wlan|fon_ata|sl_wlan)([._]?(beta|labor|labbeta))?([.]Annex[AB])?(([.]en|[.]int|[.]de|[.]it|-en|-de|-es|-it|-fr|-pl|-nl)*)?([.][0-9]{2,3}[.]0[0-9][.][0-9]{2}(-[0-9]+)?)[.]image");
    std::regex pattern2("[.]image$");

    // Extract the relevant part from the filename using regex
    std::smatch match;
    std::string result;

    if (std::regex_search(filename, match, pattern1)) {
        debug && std::cerr << "found pattern 1. result:" << result << std::endl;
        result = match.str(1) + match.str(7) + match.str(9);
    }
    else {
        result = filename;
    }

    // Remove the ".image" extension if present
    result = std::regex_replace(result, pattern2, "");
    debug && std::cerr << "removed .image extension. result:" << result << std::endl;

    // Convert the result to lowercase
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    debug && std::cerr << "converted to lowercase. result:" << result << std::endl;

    return result;
}

int main() {
    std::string filename;
    std::getline(std::cin, filename);

    debug && std::cerr << "main: filename: " << filename << std::endl;

    std::string id = convertImageFilenameToId(filename);

    std::cout << id << std::endl;

    return 0;
}
