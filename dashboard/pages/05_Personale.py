"""Personale — Evoluzione del corpo docente e ricercatore."""

import plotly.graph_objects as go
import streamlit as st

from sources import fmt_num, fmt_pct, load_mart, YEARS

st.title("Personale")
st.caption("Evoluzione del personale accademico italiano")

year = st.selectbox("Anno", YEARS, index=len(YEARS) - 1)

df_all = load_mart("mur_personale", "mart_personale_distribuzione", 2025)
df = df_all[df_all["anno"] == year]

if df.empty:
    st.warning("Dati non disponibili.")
    st.stop()

k1, k2 = st.columns(2)
k1.metric("Totale personale", fmt_num(int(df["totale"].sum())))
k2.metric("% Donne", f"{df['pct_donne'].mean():.1f}%")

# Qualifiche
st.subheader("Composizione per qualifica")
df_qual = df.groupby("desc_qualifica", as_index=False).agg(totale=("totale", "sum"), pct_donne=("pct_donne", "mean")).sort_values("totale", ascending=True)

fig = go.Figure(go.Bar(x=df_qual["totale"], y=df_qual["desc_qualifica"], orientation="h", marker_color="#6366f1", text=df_qual["totale"].apply(lambda x: fmt_num(int(x))), textposition="outside"))
fig.update_layout(height=max(300, len(df_qual) * 40), xaxis_title="Unità", margin={"l": 250, "r": 20, "t": 10, "b": 40}, showlegend=False)
st.plotly_chart(fig, width="stretch")

st.divider()

# % Donne
st.subheader("% Donne per qualifica")
fig2 = go.Figure(go.Bar(x=df_qual["pct_donne"], y=df_qual["desc_qualifica"], orientation="h", marker_color=df_qual["pct_donne"].apply(lambda x: "#ec4899" if x > 55 else "#6366f1" if x > 45 else "#3b82f6"), text=df_qual["pct_donne"].apply(lambda x: f"{x:.1f}%"), textposition="outside"))
fig2.add_vline(x=50, line_dash="dash", line_color="gray", annotation_text="Parità")
fig2.update_layout(height=max(300, len(df_qual) * 40), xaxis_title="% Donne", xaxis=dict(range=[0, 75]), margin={"l": 250, "r": 20, "t": 10, "b": 40}, showlegend=False)
st.plotly_chart(fig2, width="stretch")

st.divider()

# Trend
st.subheader("Evoluzione temporale")
trend = df_all.groupby(["anno", "desc_qualifica"], as_index=False).agg(totale=("totale", "sum"))
fig3 = go.Figure()
for qual in trend["desc_qualifica"].unique():
    df_q = trend[trend["desc_qualifica"] == qual]
    fig3.add_trace(go.Scatter(x=df_q["anno"], y=df_q["totale"], name=qual, mode="lines"))
fig3.update_layout(height=400, yaxis_title="Unità", xaxis_title="Anno", margin={"t": 20, "b": 40}, legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1))
st.plotly_chart(fig3, width="stretch")
