"""Finanza — Gettito contribuzione studentesca."""

import pandas as pd
import plotly.graph_objects as go
import streamlit as st

from sources import fmt_pct, load_mart, YEARS

st.title("Finanza")
st.caption("Quanto costa l'università agli studenti")

# Carica tutti gli anni del contribuzione (ogni file mart contiene l'anno precedente)
contrib_years = list(range(2017, 2025))
df_all = pd.concat([load_mart("mur_contribuzione_universitaria", "mart_contribuzione_trend", y) for y in contrib_years], ignore_index=True)
df_all = df_all.drop_duplicates(subset=["anno", "descrizione_gettito"])

anni_contrib = sorted(df_all["anno"].unique())
year = st.selectbox("Anno", anni_contrib, index=len(anni_contrib) - 1)

df = df_all[df_all["anno"] == year]

if df.empty:
    st.warning("Dati non disponibili.")
    st.stop()

k1, k2 = st.columns(2)
totale = df["totale_euro"].sum()
k1.metric("Gettito totale", f"€ {totale / 1_000_000:.1f} M")
if year > min(anni_contrib):
    df_prev = df_all[df_all["anno"] == year - 1]
    totale_prev = df_prev["totale_euro"].sum()
    var = ((totale - totale_prev) / totale_prev * 100) if totale_prev > 0 else 0
    k2.metric("Variazione YoY", fmt_pct(var))
else:
    k2.metric("Anno", str(year))

st.divider()

# Ripartizione
st.subheader("Ripartizione per tipo")
df_bar = df.sort_values("milioni", ascending=True)
fig = go.Figure(go.Bar(x=df_bar["milioni"], y=df_bar["descrizione_gettito"], orientation="h", marker_color="#6366f1", text=df_bar["milioni"].apply(lambda x: f"€ {x:.0f}M"), textposition="outside"))
fig.update_layout(height=max(300, len(df_bar) * 35), xaxis_title="Milioni €", margin={"l": 300, "r": 20, "t": 10, "b": 40}, showlegend=False)
st.plotly_chart(fig, width="stretch")

st.divider()

# Trend
st.subheader("Evoluzione nel tempo")
fig2 = go.Figure()
for tipo in df_all["descrizione_gettito"].unique():
    df_t = df_all[df_all["descrizione_gettito"] == tipo].sort_values("anno")
    fig2.add_trace(go.Scatter(x=df_t["anno"], y=df_t["totale_euro"] / 1_000_000, name=tipo, mode="lines+markers"))
fig2.update_layout(height=550, yaxis_title="Milioni €", xaxis_title="Anno", margin={"t": 20, "b": 120, "l": 60, "r": 20}, legend=dict(font=dict(size=8), yanchor="top", y=-0.45, xanchor="center", x=0.5, orientation="h"))
st.plotly_chart(fig2, width="stretch")
