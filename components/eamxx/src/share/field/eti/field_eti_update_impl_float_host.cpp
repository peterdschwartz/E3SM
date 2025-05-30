#include "share/field/field.hpp"

namespace scream {

template void Field::update_impl<CombineMode::Update,  Host, false, float, float>(const Field&, const float, const float);
template void Field::update_impl<CombineMode::Multiply,Host, false, float, float>(const Field&, const float, const float);
template void Field::update_impl<CombineMode::Divide,  Host, false, float, float>(const Field&, const float, const float);

template void Field::update_impl<CombineMode::Update,  Host, false, float, int>(const Field&, const float, const float);
template void Field::update_impl<CombineMode::Multiply,Host, false, float, int>(const Field&, const float, const float);
template void Field::update_impl<CombineMode::Divide,  Host, false, float, int>(const Field&, const float, const float);

} // namespace scream
