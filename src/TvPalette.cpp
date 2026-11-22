#include "TvPalette.h"

#include <QMetaType>
#include <iterator>

namespace qmltui::tvision {

const TvPalette::ColorTokenEntry TvPalette::s_colorTokens[] = {
    {"desktopBg", &TvPalette::m_desktopBg},
    {"desktopFg", &TvPalette::m_desktopFg},
    {"barBg", &TvPalette::m_barBg},
    {"barFg", &TvPalette::m_barFg},
    {"barHotkeyFg", &TvPalette::m_barHotkeyFg},
    {"barSelectedBg", &TvPalette::m_barSelectedBg},
    {"barSelectedFg", &TvPalette::m_barSelectedFg},
    {"barSelectedHotkeyFg", &TvPalette::m_barSelectedHotkeyFg},
    {"barDisabledFg", &TvPalette::m_barDisabledFg},
    {"barBorderFg", &TvPalette::m_barBorderFg},
    {"winBg", &TvPalette::m_winBg},
    {"winFg", &TvPalette::m_winFg},
    {"winMutedFg", &TvPalette::m_winMutedFg},
    {"winActiveBorder", &TvPalette::m_winActiveBorder},
    {"winInactiveBorder", &TvPalette::m_winInactiveBorder},
    {"winMoveBorder", &TvPalette::m_winMoveBorder},
    {"winControlFg", &TvPalette::m_winControlFg},
    {"winScrollBg", &TvPalette::m_winScrollBg},
    {"winScrollFg", &TvPalette::m_winScrollFg},
    {"dialogBg", &TvPalette::m_dialogBg},
    {"dialogFg", &TvPalette::m_dialogFg},
    {"dialogMutedFg", &TvPalette::m_dialogMutedFg},
    {"dialogActiveBorder", &TvPalette::m_dialogActiveBorder},
    {"dialogInactiveBorder", &TvPalette::m_dialogInactiveBorder},
    {"dialogControlFg", &TvPalette::m_dialogControlFg},
    {"inputBg", &TvPalette::m_inputBg},
    {"inputFg", &TvPalette::m_inputFg},
    {"listBg", &TvPalette::m_listBg},
    {"listFg", &TvPalette::m_listFg},
    {"listSelectedBg", &TvPalette::m_listSelectedBg},
    {"listSelectedFg", &TvPalette::m_listSelectedFg},
    {"buttonBg", &TvPalette::m_buttonBg},
    {"buttonFocusedBg", &TvPalette::m_buttonFocusedBg},
    {"buttonFg", &TvPalette::m_buttonFg},
    {"buttonDefaultFg", &TvPalette::m_buttonDefaultFg},
    {"buttonHotkeyFg", &TvPalette::m_buttonHotkeyFg},
    {"buttonShadowFg", &TvPalette::m_buttonShadowFg},
};

namespace {

bool parseColorVariant(const QVariant &val, qmltui::Color *out) {
  if (!val.isValid() || val.isNull())
    return false;
  if (val.metaType() == QMetaType::fromType<qmltui::Color>()) {
    const qmltui::Color c = val.value<qmltui::Color>();
    if (!c.isValid())
      return false;
    *out = c;
    return true;
  }
  if (val.typeId() == QMetaType::QString || val.canConvert<QString>()) {
    const qmltui::Color c = qmltui::Color::fromString(val.toString());
    if (!c.isValid())
      return false;
    *out = c;
    return true;
  }
  return false;
}

} // namespace

TvPalette::TvPalette(QObject *parent) : QObject(parent) {}

void TvPalette::reset() {
  const TvPalette defaults;
  copyFrom(&defaults);
}

void TvPalette::copyFrom(const TvPalette *source) {
  if (!source || source == this)
    return;

  bool changed = false;
  auto assignField = [&changed](auto &dst, const auto &src) {
    if (dst != src) {
      dst = src;
      changed = true;
    }
  };

  assignField(m_schemeId, source->m_schemeId);
  assignField(m_schemeTitle, source->m_schemeTitle);
  assignField(m_description, source->m_description);
  assignField(m_isMonochrome, source->m_isMonochrome);

  for (const ColorTokenEntry &entry : s_colorTokens)
    assignField(this->*(entry.member), source->*(entry.member));

  if (changed)
    emit paletteChanged();
}

bool TvPalette::applyMap(const QVariantMap &tokens) {
  if (tokens.isEmpty())
    return false;

  bool recognized = false;
  bool changed = false;

  auto applyStringKey = [&](QLatin1StringView key, QString &dst) {
    const auto it = tokens.find(key);
    if (it == tokens.cend() || !it->isValid() || it->isNull())
      return;
    recognized = true;
    const QString next = it->toString();
    if (dst != next) {
      dst = next;
      changed = true;
    }
  };

  applyStringKey(QLatin1StringView("schemeId"), m_schemeId);
  applyStringKey(QLatin1StringView("schemeTitle"), m_schemeTitle);
  applyStringKey(QLatin1StringView("description"), m_description);

  const auto monoIt = tokens.find(QLatin1StringView("isMonochrome"));
  if (monoIt != tokens.cend() && monoIt->isValid() && !monoIt->isNull()) {
    recognized = true;
    const bool nextMono = monoIt->toBool();
    if (m_isMonochrome != nextMono) {
      m_isMonochrome = nextMono;
      changed = true;
    }
  }

  for (const ColorTokenEntry &entry : s_colorTokens) {
    const auto it = tokens.find(QLatin1StringView(entry.name));
    if (it == tokens.cend())
      continue;
    qmltui::Color parsed;
    if (!parseColorVariant(*it, &parsed))
      continue;
    recognized = true;
    if (this->*(entry.member) != parsed) {
      this->*(entry.member) = parsed;
      changed = true;
    }
  }

  if (changed)
    emit paletteChanged();
  return recognized;
}

QVariantMap TvPalette::toMap() const {
  QVariantMap out;
  out.insert(QStringLiteral("schemeId"), m_schemeId);
  out.insert(QStringLiteral("schemeTitle"), m_schemeTitle);
  out.insert(QStringLiteral("description"), m_description);
  out.insert(QStringLiteral("isMonochrome"), m_isMonochrome);
  for (const ColorTokenEntry &entry : s_colorTokens)
    out.insert(QLatin1StringView(entry.name),
               (this->*(entry.member)).toString());
  return out;
}

} // namespace qmltui::tvision
