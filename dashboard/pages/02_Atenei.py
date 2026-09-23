"""Atenei — Classifica e scheda singolo ateneo."""

import plotly.graph_objects as go
import streamlit as st

from sources import fmt_num, fmt_pct, load_mart, YEARS

st.title("Atenei")
st.caption("Classifica e dettaglio dei singoli atenei")

year = st.selectbox("Anno", YEARS, index=len(YEARS) - 1)

df_all = load_mart("mur_iscritti", "mart_iscritti_concentrazione", 2025)
df = df_all[df_all["anno"] == year]
df_lau_all = load_mart("mur_laureati", "mart_laureati_efficienza", 2025)
df_lau = df_lau_all[df_lau_all["anno"] == year]

if df.empty:
    st.warning("Dati non disponibili.")
    st.stop()

# Classifica
st.subheader("Classifica per dimensione")
df_c = df[["ateneo_cod", "ateneo_nome", "totale", "donne", "uomini", "pct_donne", "macro_area"]].sort_values("totale", ascending=False).reset_index(drop=True)
df_c.index += 1
df_c.index.name = "#"
st.dataframe(df_c.rename(columns={"ateneo_nome": "Ateneo", "totale": "Iscritti", "donne": "Donne", "uomini": "Uomini", "pct_donne": "% Donne", "macro_area": "Area"}), width="stretch", height=500)

st.divider()

# Scheda ateneo
st.subheader("Scheda ateneo")
sel = st.selectbox("Seleziona ateneo", sorted(df["ateneo_nome"].unique()))

if sel:
    row = df[df["ateneo_nome"] == sel].iloc[0]
    row_l = df_lau[df_lau["ateneo_nome"] == sel] if not df_lau.empty else None

    c1, c2, c3 = st.columns(3)
    c1.metric("Iscritti", fmt_num(int(row["totale"])))
    c2.metric("Laureati", fmt_num(int(row_l["totale"].sum())) if row_l is not None and not row_l.empty else "—")
    c3.metric("% Donne", fmt_pct(row["pct_donne"], signed=False))

    # Trend singolo ateneo
    trend = df_all[df_all["ateneo_nome"] == sel].groupby("anno", as_index=False).agg(totale=("totale", "sum"))
    if not trend.empty:
        fig = go.Figure(go.Scatter(x=trend["anno"], y=trend["totale"], mode="lines+markers", line=dict(color="#6366f1", width=2)))
        fig.update_layout(height=300, title=f"Iscritti — {sel}", yaxis_title="Iscritti", xaxis_title="Anno", margin={"t": 40, "b": 40})
        st.plotly_chart(fig, width="stretch")
