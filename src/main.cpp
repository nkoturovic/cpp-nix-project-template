#include <print>
#include <nlohmann/json.hpp>

int main (int argc, char *argv[])
{
    nlohmann::json j;
    j["message"] = "Hello world";
  
    std::println("{}", j.dump(2));

    return 0;
}
