"""Finanza — Gettito contribuzione studentesca."""

import plotly.graph_objects as go
import streamlit as st

from sources import fmt_num, load_mart, YEARS

st.title("Finanza")
st.caption("Quanto costa l'università agli studenti")

anni_contrib = sorted(load_mart("mur_contribuzione_universitaria", "mart_contribuzione_trend", 2024)["anno"].unique())
year = st.selectbox("Anno", anni_contrib, index=len(anni_contrib) - 1)

df_all = load_mart("mur_contribuzione_universitaria", "mart_contribuzione_trend", 2024)
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
    k2.metric("Variazione YoY", f"{var:+.1f}%")
else:
    k2.metric("Anno", str(year))

st.divider()

# Ripartizione
st.subheader("Ripartizione per tipo")
fig = go.Figure(go.Bar(x=df["descrizione_gettito"], y=df["milioni"], marker_color="#6366f1", text=df["milioni"].apply(lambda x: f"€ {x:.1f}M"), textposition="outside"))
fig.update_layout(height=350, yaxis_title="Milioni €", margin={"t": 20, "b": 80}, showlegend=False, xaxis_tickangle=-45)
st.plotly_chart(fig, width="stretch")

st.divider()

# Trend
st.subheader("Evoluzione nel tempo")
fig2 = go.Figure()
for tipo in df_all["descrizione_gettito"].unique():
    df_t = df_all[df_all["descrizione_gettito"] == tipo]
    fig2.add_trace(go.Scatter(x=df_t["anno"], y=df_t["totale_euro"] / 1_000_000, name=tipo, mode="lines+markers"))
fig2.update_layout(height=400, yaxis_title="Milioni €", xaxis_title="Anno", margin={"t": 20, "b": 40}, legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1))
st.plotly_chart(fig2, width="stretch")
