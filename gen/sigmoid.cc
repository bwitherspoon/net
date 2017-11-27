#include <iostream>
#include <boost/program_options.hpp>
#include "sigmoid.h"

namespace po = boost::program_options;

int main(int argc, char *argv[])
{
  bool deriv = false;
  int width = 0;
  int depth = 0;

  try {
    po::options_description desc{"Options"};
    desc.add_options()
      ("help,h", "Help")
      ("prime,p", po::bool_switch(&deriv), "Derivative")
      ("width,w", po::value<int>(&width)->default_value(8), "Width")
      ("depth,d", po::value<int>(&depth)->default_value(4096), "Depth");

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    if (vm.count("help")) {
      std::cout << desc;
      return 0;
    }

  } catch (const po::error& ex) {
    std::cerr << ex.what() << std::endl;
  }

  machina::Sigmoid sigmoid(width, deriv);

  for (int val = 0; val < depth >> 1; val++)
    sigmoid << val;
  for (int val = -(depth >> 1); val < 0; val++)
    sigmoid << val;

  std::cout << sigmoid;

  return 0;
}
